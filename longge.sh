#!/usr/bin/env bash
# 龍哥伪装网站检测 v1.0
# 用途：检测 Reality 伪装域名(SNI)的 TLS 握手延迟，并检查是否支持 TLS1.3 + HTTP/2
# 用法：bash longge.sh                  使用内置域名列表
#       bash longge.sh a.com b.com      只检测指定域名
# 说明：所有域名并发检测，速度快；仅发起 HTTPS 请求，不写文件、不改系统配置

TIMEOUT=3

DOMAINS=(
    "www.icloud.com" "www.apple.com" "xp.apple.com"
    "www.amazon.com" "aws.amazon.com" "vs.aws.amazon.com"
    "www.microsoft.com" "www.xbox.com" "www.oracle.com"
    "www.nvidia.com" "images.nvidia.com" "www.amd.com"
    "www.intel.com" "www.sony.com" "www.tesla.com"
    "www.cloudflare.com" "www.samsung.com" "www.dell.com"
)
[ $# -gt 0 ] && DOMAINS=("$@")

command -v curl >/dev/null 2>&1 || { echo "请先安装 curl"; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo -e "\n\033[1;36m=========================================\033[0m"
echo -e "\033[1;36m            龍哥伪装网站检测\033[0m"
echo -e "\033[1;36m=========================================\033[0m"
echo -e "正在并发检测 ${#DOMAINS[@]} 个域名（超时 ${TIMEOUT}s）...\n"

check() {
    local idx=$1 d=$2 r
    r=$(curl -s -o /dev/null -m "$TIMEOUT" --tlsv1.3 --http2 \
        -w '%{time_appconnect} %{http_version}' "https://$d" 2>/dev/null)
    echo "$d $r" > "$tmp/$idx"
}

i=0
for d in "${DOMAINS[@]}"; do
    i=$((i + 1))
    check "$i" "$d" &
done
wait

# 排序规则：1=TLS1.3+H2 正常(按延迟升序)  2=缺少H2  3=失败/超时
cat "$tmp"/* 2>/dev/null | awk '{
    d=$1; t=$2+0; v=$3
    if (t>0 && v=="2")      printf "1 %d %s\n", t*1000, d
    else if (t>0)           printf "2 %d %s\n", t*1000, d
    else                    printf "3 99999 %s\n", d
}' | sort -k1,1n -k2,2n | awk '{
    if ($1==1)      printf "  \033[1;32m%-26s %5d ms   TLS1.3 + H2  推荐\033[0m\n", $3, $2
    else if ($1==2) printf "  \033[1;33m%-26s %5d ms   不支持 H2   不推荐\033[0m\n", $3, $2
    else            printf "  \033[1;31m%-26s 超时/不支持 TLS1.3\033[0m\n", $3
}'

echo -e "\n\033[1;36m=========================================\033[0m"
echo -e "检测完成！优先选择绿色且延迟低的域名，填入 Reality 的 dest / serverNames。"
echo -e "提示：请在你的 VPS 上运行，结果才代表 VPS 到该域名的真实延迟。\n"
