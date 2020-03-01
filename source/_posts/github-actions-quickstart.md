---
title: Github Actions示例
date: 2020-03-01 01:39:22
categories:
- CI/CD
tags:
- github
thumbnail: /gallery/github-workflow.png
---

在项目根目录创建目录`.github/workflows`，在这个目录下创建workflo文件。

development.yml：
```
name: Development Workflow
on: [push]

jobs:
  test:
    name: CI Pipeline
    runs-on: ubuntu-latest
    steps:
      - name: Checkout master
        uses: actions/checkout@v1
      - name: Set up Ruby 2.6
        uses: actions/setup-ruby@v1
        with:
          ruby-version: 2.6.x
      - name: Setup bundler and required gems
        run: |
          gem install bundler
          bundle install --jobs 4 --retry 3
      - name: Build and test the websites
        run: bundle exec rake
  deploy:
    name: CD Pipeline QA
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: webfactory/ssh-agent
        uses: webfactory/ssh-agent@v0.1.1
        with:
          ssh-private-key: ${{ secrets.SSH_QA_PRIVATE_KEY }}
      - name: Checkout master
        uses: actions/checkout@v1
      - name: Setup Ruby 2.6
        uses: actions/setup-ruby@v1
        with:
          ruby-version: 2.6.x
      - name: Set up lftp
        run: sudo apt-get install lftp -y
      - name: Setup bundler and required gems
        run: |
          gem install bundler
          bundle install --jobs 4 --retry 3
      - name: Build and deploy the website to QA
        run: bundle exec rake deploy:qa
        env:
          SSH_DEPLOY_SERVER: ${{ secrets.SSH_QA_DEPLOY_SERVER }}
          SSH_DEPLOY_USER: ${{ secrets.SSH_QA_DEPLOY_USER }}
```

release.yml：
```
name: Release Workflow
on:
  push:
    tags:
      - "v*"

jobs:
  test:
    name: CI Pipeline
    runs-on: ubuntu-latest
    steps:
      - name: Checkout master
        uses: actions/checkout@v1
      - name: Set up Ruby 2.6
        uses: actions/setup-ruby@v1
        with:
          ruby-version: 2.6.x
      - name: Setup bundler and required gems
        run: |
          gem install bundler
          bundle install --jobs 4 --retry 3
      - name: Build and test the websites
        run: bundle exec rake
  deploy:
    name: CD Pipeline PRD
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: webfactory/ssh-agent
        uses: webfactory/ssh-agent@v0.1.1
        with:
          ssh-private-key: ${{ secrets.SSH_PROD_PRIVATE_KEY }}
      - name: Checkout master
        uses: actions/checkout@v1
      - name: Set up Ruby 2.6
        uses: actions/setup-ruby@v1
        with:
          ruby-version: 2.6.x
      - name: Set up lftp
        run: sudo apt-get install lftp -y
      - name: Setup bundler and required gems
        run: |
          gem install bundler
          bundle install --jobs 4 --retry 3
      - name: Build and deploy the website to PRD
        run: bundle exec rake deploy:production
        env:
          SSH_DEPLOY_SERVER: ${{ secrets.SSH_PROD_DEPLOY_SERVER }}
          SSH_DEPLOY_USER: ${{ secrets.SSH_PROD_DEPLOY_USER }}
```

## 引用

+ [thbe.org](https://www.thbe.org/posts/2019/12/03/Github_actions_-_CI.html)
