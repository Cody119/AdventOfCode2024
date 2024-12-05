defualt: build

BUILD_DIR=build
FILE=day3

.PHONY: build
build:
	mkdir -p ${BUILD_DIR}
	nasm -felf64 -o ${BUILD_DIR}/${FILE}.o ${FILE}.nasm
	ld -o ${BUILD_DIR}/${FILE} ${BUILD_DIR}/${FILE}.o

.PHONY: clean
clean:
	rm -rf ${BUILD_DIR}

.PHONY: run
run:
	./${BUILD_DIR}/${FILE}
