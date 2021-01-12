#!/bin/bash +x

function SetTegraBuildEnv()
{
    PROJECT_NAME=${1}
    JETPACK_VERSION=${2}
    EMPLOYEE_ID=${3}
    EMPLOYEE_PW=${4}

    echo "PROJECT_NAME=${PROJECT_NAME}"
    echo "JETPACK_VERSION=${JETPACK_VERSION}"

    echo "Start git clone BSP source"
    cd ${WORKSPACE}
    if [ "${PROJECT_NAME}" = "EN715" ]; then
        GIT_URL="ssh://a001737@CodeReview-New.avermedia.com:29418/BSP/Jetson/EN715"
        REPO_NAME="EN715"
        BRANCH_NAME="master"    
    elif [ "$PROJECT_NAME" = "EN713" ]; then
        GIT_URL="ssh://a001737@CodeReview-New.avermedia.com:29418/BSP/Jetson/EN715"
        REPO_NAME="EN715"
        BRANCH_NAME="EN713"
    elif [ "$PROJECT_NAME" = "NO101TI" ]; then
        GIT_URL="ssh://a001737@CodeReview-New.avermedia.com:29418/BSP/Jetson/EN715"
        REPO_NAME="EN715"
        BRANCH_NAME="NO101TI"
    elif [ "$PROJECT_NAME" = "NO135K" ]; then
        GIT_URL="ssh://a001737@CodeReview-New.avermedia.com:29418/BSP/Jetson/EN715"
        REPO_NAME="EN715"
        BRANCH_NAME="NO135K"
    elif [ "$PROJECT_NAME" = "EX731" ]; then
        GIT_URL="ssh://a001737@CodeReview-New.avermedia.com:29418/BSP/Jetson/EX731"
        REPO_NAME="EX731"
        BRANCH_NAME="master"
    elif [ "$PROJECT_NAME" = "EN715-NX" ]; then
        GIT_URL="ssh://a001737@CodeReview-New.avermedia.com:29418/BSP/Jetson/NX201"
        REPO_NAME="NX201"
        BRANCH_NAME="master"
    elif [ "$PROJECT_NAME" = "EN713-NX" ]; then
        GIT_URL="ssh://a001737@CodeReview-New.avermedia.com:29418/BSP/Jetson/NX201"
        REPO_NAME="NX201"
        BRANCH_NAME="EN713-NX"
    elif [ "$PROJECT_NAME" = "NX201F" ]; then
        GIT_URL="ssh://a001737@CodeReview-New.avermedia.com:29418/BSP/Jetson/NX201"
        REPO_NAME="NX201"
        BRANCH_NAME="NX201F"
    elif [ "$PROJECT_NAME" = "NX201C" ]; then
        GIT_URL="ssh://a001737@CodeReview-New.avermedia.com:29418/BSP/Jetson/NX201"
        REPO_NAME="NX201"
        BRANCH_NAME="NX201C"
    fi

    echo "Start clone source from gerrit server"
    git clone ${GIT_URL}
    if [ "${BRANCH_NAME}" != "master" ]; then
        mv ${REPO_NAME} ${PROJECT_NAME}
        cd ${PROJECT_NAME}
        git checkout ${BRANCH_NAME}
    else
        if [ "${REPO_NAME}" != "${PROJECT_NAME}" ]; then
            mv ${REPO_NAME} ${PROJECT_NAME}
        fi
        cd ${PROJECT_NAME}
    fi

    CONFIG_SRC_FILE="${WORKSPACE}/${PROJECT_NAME}/config_src"
    echo "CONFIG_SRC_FILE=${CONFIG_SRC_FILE}"
    source ${CONFIG_SRC_FILE}

    git submodule init
    git submodule update

    echo "Get the latest Jetson_build_script"
    cd Jetson_build_script
    git fetch "ssh://a001737@CodeReview-New.avermedia.com:29418/BSP/Jetson/Jetson_build_script" refs/changes/62/22662/1 && git checkout FETCH_HEAD


    echo "Create download cache folder"
    JETPACK_DOWNLOAD_FOLDER="${WORKSPACE}/SOURCE_CACHE"
    mkdir -p "${JETPACK_DOWNLOAD_FOLDER}"

    echo "Specified JETPACK_DOWNLOAD_FOLDER=${JETPACK_DOWNLOAD_FOLDER}"
    export JETPACK_DOWNLOAD_FOLDER=${JETPACK_DOWNLOAD_FOLDER}

    cd ${WORKSPACE}

    echo "Create build folder"
    mkdir -p build

    if [ "$JETPACK_VERSION" = "4.4" ]; then
        L4T_VERSION="r32.4.3"
    elif [ "$JETPACK_VERSION" = "4.4.1" ]; then
        L4T_VERSION="r32.4.4"
    fi

    if [ "$REPO_NAME" = "EN715" ]; then
        JETPACK_SRC="JetPack_${JETPACK_VERSION}_Linux_JETSON_NANO"
        L4T_SRC="tegra-l4t-nano-${L4T_VERSION}_src"
    elif [ "$REPO_NAME" = "EX731" ]; then
        JETPACK_SRC="JetPack_${JETPACK_VERSION}_Linux_JETSON_TX2"
        L4T_SRC="tegra-l4t-tx2-${L4T_VERSION}_src"
    elif [ "$REPO_NAME" = "NX201" ]; then
        JETPACK_SRC="JetPack_${JETPACK_VERSION}_Linux_JETSON_XAVIER_NX"
        L4T_SRC="tegra-l4t-xavier-nx-${L4T_VERSION}_src"
    fi

    PROJECT_BUILD_FOLDER="${WORKSPACE}/build"

    echo "Start init config"
    echo "BUILD_SCRIPT_LOCATION=${WORKSPACE}/${PROJECT_NAME}/Jetson_build_script" >> ${WORKSPACE}/${PROJECT_NAME}/config
    echo "USER=jenkins" >> ${WORKSPACE}/${PROJECT_NAME}/config
    echo "export LOCALVERSION=-tegra  # in order to compatible with NVidia default rootfs" >> ${WORKSPACE}/${PROJECT_NAME}/config
    echo "PROJECT_NAME=${PROJECT_NAME}" >> ${WORKSPACE}/${PROJECT_NAME}/config
    echo "l4t_parent_directory_and_tar_name=${JETPACK_SRC}" >> ${WORKSPACE}/${PROJECT_NAME}/config
    echo "clean_l4t_tar=${JETPACK_DOWNLOAD_FOLDER}/${JETPACK_SRC}.tar.gz" >> ${WORKSPACE}/${PROJECT_NAME}/config
    echo "build_folder=${PROJECT_BUILD_FOLDER}" >> ${WORKSPACE}/${PROJECT_NAME}/config
    echo "target_directory=${WORKSPACE}/${PROJECT_NAME}" >> ${WORKSPACE}/${PROJECT_NAME}/config
    echo "Linux_for_Tegra=${PROJECT_BUILD_FOLDER}/${JETPACK_SRC}/Linux_for_Tegra" >> ${WORKSPACE}/${PROJECT_NAME}/config
    echo "SOURCE_PATH=${PROJECT_BUILD_FOLDER}/${L4T_SRC}" >> ${WORKSPACE}/${PROJECT_NAME}/config
    echo "export TEGRA_KERNEL_OUT=${PROJECT_BUILD_FOLDER}/${L4T_SRC}/kernel/kernel-4.9/builtKernel" >> ${WORKSPACE}/${PROJECT_NAME}/config
    echo "export CROSS_COMPILE=/opt/gcc-linaro/bin/aarch64-linux-gnu-" >> ${WORKSPACE}/${PROJECT_NAME}/config

    PROJECT_DIR=${WORKSPACE}/${PROJECT_NAME}
    echo "PROJECT_DIR=${PROJECT_DIR}" >> ${WORKSPACE}/${PROJECT_NAME}/config
    target_version=$(cat ${PROJECT_DIR}/L4T_bin/rootfs/etc/avt_tegra_release | head -n 1)
    echo "target_version=${target_version}" >> ${WORKSPACE}/${PROJECT_NAME}/config
    echo "output_tar=${target_version}.tar.gz" >> ${WORKSPACE}/${PROJECT_NAME}/config

    echo "Start init BspSourceConfig"
    echo "PROJECT_BUILD_FOLDER=${PROJECT_BUILD_FOLDER}" >> ${WORKSPACE}/${PROJECT_NAME}/BspSourceConfig
    echo "JETPACK_DOWNLOAD_FOLDER=${JETPACK_DOWNLOAD_FOLDER}" >> ${WORKSPACE}/${PROJECT_NAME}/BspSourceConfig
    echo "JETPACK_SRC=$JETPACK_SRC" >> ${WORKSPACE}/${PROJECT_NAME}/BspSourceConfig
    echo "L4T_SRC=$L4T_SRC" >> ${WORKSPACE}/${PROJECT_NAME}/BspSourceConfig
    echo "COMPILE_CBOOT=${BUILD_CBOOT}" >> ${WORKSPACE}/${PROJECT_NAME}/BspSourceConfig

    echo "Start download JetPack & L4T original file to cache folder"
    SOURCE_SERVER_PATH="//twfs01.avermedia.com/_Department-TWA00329-RD Department II/_Project_/Internal/Vendor/NVIDIA/sources"
    MOUNT_PATH="${WORKSPACE}/REMOTE_SERVER"
    mkdir -p ${MOUNT_PATH}

    sudo mount -t cifs -o rw,username=${EMPLOYEE_ID},password=${EMPLOYEE_PW} "${SOURCE_SERVER_PATH}" ${MOUNT_PATH}

    echo "Download ${L4T_SRC}.tar.gz"
    cp ${MOUNT_PATH}/l4t/${L4T_SRC}.tar.gz ${JETPACK_DOWNLOAD_FOLDER}/

    echo "Download ${JETPACK_SRC}.tar.gz"
    cp ${MOUNT_PATH}/JetPack/${JETPACK_SRC}.tar.gz ${JETPACK_DOWNLOAD_FOLDER}/

    sudo umount ${MOUNT_PATH}
}

SetTegraBuildEnv $1 $2 $3 $4