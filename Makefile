compose:
	docker compose up -d && echo "use 'docker compose down' to turn jupyter lab off"

build:
	docker build -f jupyter.dockerfile -t jupyter-lab .

run:
	docker run \
		-ti -p 8888:8888 \
		-v "${PWD}":/home/jovyan/work \
		jupyter-lab /bin/zsh -c "SHELL=/bin/zsh start.sh jupyter lab --ip='0.0.0.0' --port=8888 --no-browser --allow-root --notebook-dir=/home/jovyan/work"
