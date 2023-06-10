# GPT 相关

[toc]

## GPT 介绍
### 发展史

![](media/16863829040836.jpg)

![](media/16863829682704.jpg)

code-davinci-002
* 加入代码，结合原本文本数据
* in-context learning，代码的逻辑性、长程依赖性强
* 续写表现好，但做东西不一定能理解人类意图

text-davinci-002/InstructGPT
* 用大量标注数据对齐意图，生成正确的内容

ChatGPT
* 收集反馈，PPO（？）强化学习

text-davinci-003
* 收集反馈，强化学习

![](media/16863835331786.jpg)

GPT-4代码能力非常强，并具备多模态理解能力。

![](media/16863835637475.jpg)

540b 参数时，大模型的**涌现效应**非常明显，模型会展现更多能力。

![](media/16863840054765.jpg)

深度学习 vs. 大模型
* 出发点：具体任务 


|            | 深度学习                                    | 大模型                                                            |
|------------|:--------------------------------------------|-------------------------------------------------------------------|
| 出发点     | 具体任务                                    | 单个领域/模态(文本/图像/语音/视频等)                              |
| 数据收集   | 特定场景，人工标注，少量数据                  | 领域数据，无标注，大量数据                                          |
| 模型实现   | ML(SVM), 神经网络(CNN/RNN), 决策树(XGBoost) | GPT自回归模型，Encoder-Decoder模型，扩散模型                        |
| 模型预训练 | -                                           | 无监督/自监督学习，预计预训练训练目标，优化损失函数（靠训练范式实现） |
| 模型训练   | 简单的建模分类/回归，优化特定的损失函数      | 1. 具体任务；2. 数据收集：任务数据，需要标注，少量数据；3.1 零样本/少量样本学习：给模型提供少量例子，prompt工程；3.2 模型微调：有监督学习，人类反馈强化学习                                                     |
| 问题       | 难以迁移到其它场景，需要重新训练             |                                                                   |


![](media/16863846553701.jpg)

![](media/16863853343212.jpg)


要点
* Transformer：模型架构/基座，取代 CNN/RNN 成为主流架构
    > [Attention is all you need[J].](https://proceedings.neurips.cc/paper/2017/file/3f5ee243547dee91fbd053c1c4a845aa-Paper.pdf)
* GPT(Generative Pre-training 生成式预训练) ：预训练范式，在数据集上进行无监督预训练（pre-training），在具体任务上进行微调（fine-tuning），即引入基于前文预测下一个词的任务
    > [Improving Language Understanding by Generative Pre-Training. OpenAI, 2018](https://www.cs.ubc.ca/~amuham01/LING530/papers/radford2018improving.pdf)
    > [Language models are unsupervised multitask learners. OpenAI blog](https://d4mucfpksywv.cloudfront.net/better-language-models/language_models_are_unsupervised_multitask_learners.pdf)

RNN核心缺陷：难以并行，模型规模难以扩大

### 技术原理

![](media/16863857167257.jpg)

Transformer 可以并行化处理

![](media/16863858759424.jpg)

> Mask Self-Attention：自注意力模块
> Feed Forward Neural Network：前向传播

![](media/16863859464603.jpg)

> 对输入进行 Tokenization：将文本切分成 token，对应到字典中的 ID上（基于单词、字母、子串等，效率不同），并对每个 ID 分配可训练的 Embedding

![](media/16863861687196.jpg)

![](media/16863861847893.jpg)

> 计算输入中每个 Token 和其它 Token 的关系，对预测下一个 Token 的影响有多少（权重加和，也即注意力机制）。
> 对比 RNN，多个 Token 进入后会遗忘之前的 Token，而 Transformer 没问题，建模能力更强。

Transformer 解决了运行效率和规模化的问题。

#### 主流大模型

![](media/16863866067953.jpg)


1. 自回归模型：GPT

    ![](media/16863867335226.jpg)
    
    > 不断预测下一个词
    
    特点
    * 从左到右做生成
        * 1代：接 Linear 做选择/分类
        * 2待：将选择/分类任务变为文本任务，统一生成范式（让模型生成 Token，生成什么就代表选择什么）

2. 自编码模型：Bert

    ![](media/16863872203264.jpg)

    > 在文本中挖空，问挖出来什么，再填回去
    > 典型 NLP 任务，能很好理解具体/关键信息，但不适合做生成式任务

3. Encoder-Decoder：T5 模型

    ![](media/16863873851754.jpg)
    
    > 问答式

4. GLM（Up的实验室）

    ![](media/16863874283892.jpg)
    
    ![](media/16863875954964.jpg)
    
    ![](media/16863877463636.jpg)
    
### 安利 CodeGeeX
    
![](media/16863878835814.jpg)
    
![](media/16863879336669.jpg)
    
![](media/16863881917679.jpg)
    
![](media/16863882907489.jpg)

* 大规模代码数据收集
    * 开源数据集
        * The Pile（代码子集，多语言）
        * CodeParrot（Python）
    * 额外爬取数据集
        * Github 优质开源
        * 清洗
    * 23种编程语言
        * 含 Python, Java, C++, JavaScript, C, Go, HTML, Rust 等
    * 超过 1580 亿 Token
        ![](media/16863883653419.jpg)
        * 将代码数据分词、Tokenization
            ![](media/16863884966903.jpg)
    
        * 为不同语言的文件加上语言标签（来自代码文件后缀）  
* 模型架构
    ![](media/16863887340101.jpg)
    
* 模型训练
    ![](media/16863888724065.jpg)
    
* 模型评估
    ![](media/16863889627136.jpg)
    ![](media/16863890528355.jpg)
    ![](media/16863891065195.jpg)
    ![](media/16863891956758.jpg)
    
