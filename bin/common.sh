check_sha256sum() {
    local fname=$1
    local sha256=$2
    echo "${sha256}  ${fname}" > ${fname}.sha256
    sha256sum -c ${fname}.sha256
    rm -f ${fname}.sha256
}

fetch_source() {
    local file=$1
    local url=$2
    if [ ! -f ${file} ]; then
        curl --insecure -fsSL -o ${file} ${url}/${file}
    fi
}

CPUS=$(cat /proc/cpuinfo | grep MHz | wc -l)
