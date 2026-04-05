#!/usr/bin/env bash
# Module: General Preparation

clone_repo() {
    if [[ ! -d $BUILD_DIR ]]; then
        echo "克隆仓库: $REPO_URL 分支: $REPO_BRANCH"
        if ! git clone --depth 1 -b $REPO_BRANCH $REPO_URL $BUILD_DIR; then
            echo "错误：克隆仓库 $REPO_URL 失败" >&2
            exit 1
        fi
    fi
}

clean_up() {
    if [[ ! -d "$BUILD_DIR" ]]; then
        echo "Build directory $BUILD_DIR does not exist"
        return
    fi
    cd "$BUILD_DIR"
    if [[ -f ".config" ]]; then
        \rm -f ".config"
    fi
    if [[ -d "tmp" ]]; then
        \rm -rf "tmp"
    fi
    if [[ -d "logs" ]]; then
        \rm -rf "logs/*"
    fi
    if [[ -d "feeds" ]]; then
        ./scripts/feeds clean
    fi
    
    echo "清除包索引缓存..."
    if [[ -d "staging_dir" ]]; then
        find "staging_dir" -name ".packageinfo" -type f -delete 2>/dev/null || true
        find "staging_dir" -name "packages" -type d -exec rm -rf {} + 2>/dev/null || true
    fi
    
    if [[ -f "tmp/.packageinfo" ]]; then
        \rm -f "tmp/.packageinfo"
    fi
    
    mkdir -p "tmp"
    echo "1" >"tmp/.build"
}

reset_feeds_conf() {
    git reset --hard origin/$REPO_BRANCH
    git clean -f -d
    git pull
    if [[ $COMMIT_HASH != "none" ]]; then
        git checkout $COMMIT_HASH
    fi
}
