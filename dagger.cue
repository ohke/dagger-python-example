package main

import (
    "dagger.io/dagger"

    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

#PythonBuild: {
    app: dagger.#FS

    image: _build.output

    _build: docker.#Build & {
        steps: [
            docker.#Pull & {
                source: "python:3.10"
            },
            docker.#Copy & {
                contents: app
                source:   "pyproject.toml"
                dest:     "/root/pyproject.toml"
            },
            docker.#Copy & {
                contents: app
                source:   "poetry.lock"
                dest:     "/root/poetry.lock"
            },
            docker.#Run & {
                command: {
                    name: "pip"
                    args: ["install", "poetry"]
                }
            },
            docker.#Run & {
                command: {
                    name: "poetry"
                    args: ["config", "virtualenvs.create", "false"]
                }
            },
            docker.#Run & {
                command: {
                    name: "poetry"
                    args: ["install"]
                }
                workdir: "/root"
            }
        ]
    }
}

dagger.#Plan & {
    client: {
        env: {
            IMAGE_NAME: string
            DOCKERHUB_USERNAME: string
            DOCKERHUB_TOKEN: dagger.#Secret
        }
        filesystem: ".": read: contents: dagger.#FS
    }

    actions: {
        params: tag: string | *"latest"

        _local_dest: "localhost:5042/\(client.env.IMAGE_NAME):\(params.tag)"
        _dockerhub_dest: "\(client.env.DOCKERHUB_USERNAME)/\(client.env.IMAGE_NAME):\(params.tag)"

        _build: #PythonBuild & {
            app: client.filesystem.".".read.contents
        }

        #Run: docker.#Run & {
            input: _build.image
            mounts: "app": {
                contents: client.filesystem.".".read.contents
                dest: "/app"
            }
            workdir: "/app"
        }

        lint: #Run & {
            command: {
                name: "flake8"
                args: ["dagger_python_example"]
            }
        }

        fmt: #Run & {
            command: {
                name: "black"
                args: ["dagger_python_example", "--check", "--diff"]
            }
        }

        test: #Run & {
            command: name: "pytest"
        }

        check: bash.#Run & {
            input: _build.image
            script: contents: #"""
                echo "success"
            """#
            env: {
                LINT: "\(lint.success)"
                FMT: "\(fmt.success)"
                TEST: "\(test.success)"
            }
        }

        buildImage: docker.#Dockerfile & {
            source: client.filesystem.".".read.contents
            dockerfile: path: "Dockerfile"
        }

        pushLocal: docker.#Push & {
            image: buildImage.output
            dest: _local_dest
        }

        pushDockerhub: docker.#Push & {
            image: buildImage.output
            auth: {
                username: client.env.DOCKERHUB_USERNAME
                secret: client.env.DOCKERHUB_TOKEN
            }
            dest: _dockerhub_dest
        }
    }
}
