TARGET=deb
PACKAGE_NAME=haproxy-exporter
PACKAGE_VERSION=0.7.1
PACKAGE_REVISION=1
PACKAGE_ARCH=amd64
PACKAGE_MAINTAINER=tristan@qubit.com
PACKAGE_FILE=$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION)_$(PACKAGE_ARCH).$(TARGET)

GITREPO=https://github.com/prometheus/haproxy_exporter.git

BINNAME=haproxy_exporter

PWD=$(shell pwd)

all: package

binary: clean-binary
	mkdir -p build/go/src
	mkdir -p build/$(PACKAGE_NAME)
	export GOPATH=$(PWD)/build/go && go get -d github.com/prometheus/haproxy_exporter
	export GOPATH=$(PWD)/build/go && cd $(PWD)/build/go/src/github.com/prometheus/haproxy_exporter && git checkout v$(PACKAGE_VERSION)
	export GOPATH=$(PWD)/build/go && cd $(PWD)/build/go/src/github.com/prometheus/haproxy_exporter && go install .
	mkdir -p dist/usr/local/bin
	install -m755 $(PWD)/build/go/bin/$(BINNAME) dist/usr/local/bin/$(BINNAME)

	mkdir -p dist/etc/init
	mkdir -p dist/etc/default
	install -m644 $(PACKAGE_NAME).conf dist/etc/init/$(PACKAGE_NAME).conf
	install -m644 $(PACKAGE_NAME).default dist/etc/default/$(PACKAGE_NAME)

clean-binary:
	rm -f dist/usr/local/bin/$(BINNAME)

package: clean binary
	cd dist && \
	  fpm \
	  -t $(TARGET) \
	  -m $(PACKAGE_MAINTAINER) \
	  -n $(PACKAGE_NAME) \
	  -a $(PACKAGE_ARCH) \
	  -v $(PACKAGE_VERSION) \
	  --iteration $(PACKAGE_REVISION) \
	  -s dir \
	  -p ../$(PACKAGE_FILE) \
	  .


clean:
	rm -f $(PACKAGE_FILE)
	rm -rf dist
	rm -rf build
