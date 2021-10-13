build:
	docker build -f jupyter.Dockerfile -t mldev .

code:
	docker run \
	-v $(WORKSPACE):/home/jovyan/work \
	-e JUPYTER_ENABLE_LAB=yes \
	-ti mldev \
	/bin/zsh -c \
	"source activate ml \
	&& code-server /home/jovyan/work/ --verbose --port $(CPORT) --auth none"

jupyter:
	docker run \
		-ti -p $(JPORT):8888 \
		--mount type=bind,source=$(WORKSPACE),target=/home/jovyan/work \
		mldev /bin/zsh -c "source activate ml && start.sh jupyter lab"

code2:
	docker run \
	--network=host \
	-v $(WORKSPACE):/home/root/workspace \
	-t mldev \
	/bin/zsh -c \
	"source activate ml \
	&& TERM=xterm code-server /home/root/workspace/ --log trace --verbose --port $(CPORT) --host 0.0.0.0 --auth none"