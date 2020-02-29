#!/bin/bash

# 安装hexo
npm install -g hexo-cli

# 创建github page项目
hexo init hudsonwu.github.io
cd hudsonwu.github.io && npm install

# ----------------------------------------
# 解决npm install时ejs安装失败的问题
# ----------------------------------------
# rm -rf node_modules
# EJS_GLOBAL_PATH=/usr/local/lib/nodejs/lib/node_modules/ejs
# npm install -g ejs@2.7.4
# mkdir node_modules
# cp -rf ${EJS_GLOBAL_PATH} node_modules
# npm install

# 安装hexo-deployer-git
npm install hexo-deployer-git --save

# 更改blog主题
git clone https://github.com/ppoffice/hexo-theme-hueman.git themes/hueman
sed -i "/theme:/s/theme/# theme/g" _config.yml
sed -i "/# theme/atheme: hueman" _config.yml
## 启用Insight Search作为默认搜索引擎
npm install -S hexo-generator-json-content
