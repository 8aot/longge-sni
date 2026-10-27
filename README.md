# longge-sni · 检测

一键检测 **Reality 伪装域名（SNI）** 的 TLS 握手延迟，并检查是否支持 **TLS 1.3 + HTTP/2**，适用于 s-ui / 3x-ui / Xray 等面板选择 `dest` / `serverNames`。

## 一键使用

在你的 **VPS** 上执行（把 `你的用户名` 换成你的 GitHub 用户名）：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/8aot/longge-sni/main/longge.sh)
```

只检测指定域名：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/你的用户名/longge-sni/main/longge.sh) www.apple.com www.amazon.com
```

> 必须在 VPS 上运行，结果才代表 VPS 到目标域名的真实延迟。

## 功能

- 并发检测，几秒出结果
- 强制 TLS 1.3，并检测 HTTP/2
- 按延迟从低到高排序，绿色为推荐，黄色为不支持 H2，红色为超时或不支持 TLS 1.3
- 支持命令行传入自定义域名
- 只发起 HTTPS 请求，不写文件、不改系统配置

## 依赖

- bash
- curl（需支持 TLS 1.3 与 HTTP/2，主流发行版默认满足）

## 安全提示

运行任何 `curl | bash` 之前，建议先查看脚本内容：

```bash
curl -Ls https://raw.githubusercontent.com/你的用户名/longge-sni/main/longge.sh | less
```

## 自定义域名列表

编辑 `longge.sh` 顶部的 `DOMAINS=( ... )` 即可。

## License

MIT
