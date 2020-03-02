---
title: Github Actions介绍
date: 2020-02-29 22:56:48
categories:
- CI/CD
tags:
- github
- idea
thumbnail: /gallery/explore-github.png
---
使用`Github Actions`可以直接在github仓库中自动化实现软件开发整个生命周期的工作流（from idea to production）。你可以编写单独的任务（称为`actions`），然后将这些任务联合以创建自定义的工作流（`workflow`），你可以设置工作流来构建、测试、打包、发布。工作流中的任务被执行的地方（主机）称为`runners`，github提供的共享runner称为`GitHub-hosted runners`，你也可以使用自己的主机来运行任务，这种主机称为`Self-hosted runners`

+ Action: 表示单个任务，多个action作为一个一个的步骤，组成job
  + action是工作流（Workflow）中最小的可移植构建块
  + 可以创建自己的actions，也可以使用或自定义github社区共享的actions
  + 可以自定义action的输入、输出以及环境变量
+ Step: 运行命令或action的单个任务
+ Job: 在同一个runner上执行的连续步骤
  + 在一个工作流文件（Workflow file）中可以定义jobs运行的依赖关系
  + jobs可以同时运行，也可以根据前一个job状态顺序运行
+ Workflow: 一个可配置的自动化流程，由一个或多个job组成
  + 可以按计划执行或被事件触发
+ Workflow file: 定义workflow配置信息的YAML文件，至少有一个job
  + workflow file保存在`.github/workflows`目录中

## Further reading

+ [官方文档介绍](https://help.github.com/en/actions)
+ [github marketplace](https://github.com/marketplace?type=actions)
+ [github community](https://github.community/t5/GitHub-Actions/bd-p/actions)
