# V2ET Shell 打包说明（GitHub Actions）

本仓库已默认在 CI 中启用 V2ET 壳层：
- `ENABLE_V2ET_SHELL=true`

## 触发方式
- 推送到 `develop` 分支会自动构建。
- 打 tag（如 `v1.0.0`）会构建并执行 release 流程。
- 也支持手动触发 `build` workflow（`workflow_dispatch`）。

## 可选参数
手动触发时可填写：
- `v2et_config_url`：运行时配置地址（对象存储 config.json）。

如果不填写，应用内使用默认配置地址（代码中的默认值）。

## 产物
- Actions 的 `build` Job 会上传 `dist` 目录为 artifact。
- tag 构建（稳定版）会进入后续 release 上传流程。
