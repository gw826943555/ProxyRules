#!/bin/sh

# url
BYPASS_IPv4_URL="https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cn.cidr"
BYPASS_IPv6_URL="https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv6/cn.cidr"
FORWARD_IPs_URL="https://raw.githubusercontent.com/SteamedFish/gfwiplist/master/gfwiplist.txt"
FORWARD_NET_URL="https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt"

# file
DST_IPS_BYPASS_FILE="./dst_ips.bypass"
DST_IPS_FORWARD_FILE="./dst_ips.forward"
DST_NET_DORWARD_FILE="./dst_net.forward"

generate_net_list() {
	cat $1 | base64 -d | \
	sed '/^@@|/d' | \
	sort -u |
		sed 's#!.\+##; s#|##g; s#@##g; s#http:\/\/##; s#https:\/\/##;' |
		sed '/\*/d; /apple\.com/d; /sina\.cn/d; /sina\.com\.cn/d; /baidu\.com/d; /byr\.cn/d; /jlike\.com/d; /weibo\.com/d; /zhongsou\.com/d; /youdao\.com/d; /sogou\.com/d; /so\.com/d; /soso\.com/d; /aliyun\.com/d; /taobao\.com/d; /jd\.com/d; /qq\.com/d' |
		sed '/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+$/d' |
		grep '^[0-9a-zA-Z\.-]\+$' | grep '\.' | sed 's#^\.\+##' | sort -u |
		awk 'BEGIN { prev = "________"; } {
		cur = $0;
		if (index(cur, prev) == 1 && substr(cur, 1 + length(prev) ,1) == ".") {
		} else {
		print cur;
		prev = cur;
		}
		}' | sort -u
}

# 获取不需要代理的IP表，包含ipv4以及ipv6地址
wget $BYPASS_IPv4_URL -O ./tmp.txt && cat ./tmp.txt > $DST_IPS_BYPASS_FILE
wget $BYPASS_IPv6_URL -O ./tmp.txt && cat ./tmp.txt >> $DST_IPS_BYPASS_FILE

# 获取需要代理的IP表，包含ipv4以及ipv6地址
wget $FORWARD_IPs_URL -O $DST_IPS_FORWARD_FILE

# 获取需要代理的域名表
wget $FORWARD_NET_URL -O ./tmp.txt
generate_net_list ./tmp.txt > $DST_NET_DORWARD_FILE

#清理临时文件
rm -f ./tmp.txt