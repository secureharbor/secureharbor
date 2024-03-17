VERSION=0.1.0
REPO=onprem
USER=secureharbor
RELEASE_FILE=secureharbor-${VERSION}
RELEASE_DIR=releases

release:	release_tar create_release upload_release

clean_release: 
	rm -rf ${RELEASE_DIR}

release_tar:   clean_release
	mkdir -p ${RELEASE_DIR}/${RELEASE_FILE}
	cp -r charts ${RELEASE_DIR}/${RELEASE_FILE}
	cp -r docs ${RELEASE_DIR}/${RELEASE_FILE}
	cp -r tests ${RELEASE_DIR}/${RELEASE_FILE}
	cp -r environments ${RELEASE_DIR}/${RELEASE_FILE}
	cp installer.sh ${RELEASE_DIR}/${RELEASE_FILE}
	cp example.secrets.yaml ${RELEASE_DIR}/${RELEASE_FILE}
	cp helmfile.yaml docker_registry.sh CHANGELOG.md ${RELEASE_DIR}/${RELEASE_FILE}
	cd ${RELEASE_DIR};tar -czvf ${RELEASE_FILE}.tar.gz ${RELEASE_FILE}

create_release:
	github-release release \
	--user ${USER} \
	--repo ${REPO} \
	--tag ${VERSION} \
	--name "${VERSION}" \
	--description "[RELEASE NOTE](https://github.com/secureharbor/onprem/wiki/${VERSION})"

upload_release:
	github-release upload \
		--user ${USER} \
		--repo ${REPO} \
		--tag ${VERSION} \
		--name "${RELEASE_FILE}.tar.gz" \
		--file ${RELEASE_DIR}/${RELEASE_FILE}.tar.gz


delete_release:
	github-release delete \
	--user ${USER} \
	--repo ${REPO} \
	--tag ${VERSION}



clean:	clean_release