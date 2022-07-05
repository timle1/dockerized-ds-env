compose:
	docker compose up -d && echo "use http://localhost:8899 or vscode connect to remote container"

setup:
	docker build -f jupyter.Dockerfile -t jupyter-lab .

run:
	docker run \
		-ti -p 8888:8888 \
		-v "${PWD}"/notebooks:/home/jovyan/ \
		jupyter-lab /bin/zsh -c "SHELL=/bin/zsh start.sh jupyter lab --ip='0.0.0.0' --port=8888 --no-browser --allow-root --notebook-dir=/home/jovyan/"

clean:
	docker compose down
	# docker container stop cont-jupyter-lab
	# docker container rm cont-jupyter-lab
	# docker rmi jupyter-lab  ## to remove image