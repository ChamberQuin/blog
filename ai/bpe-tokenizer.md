# BPE Tokenizer

# Unicode

1. **Unicode Standard**

Unicode: a mapping of character and code point (integers)

> Unicode Standard 16.0: define *154,998* characters
> Python: `ord()`, `chr()`

**Problem：**

> 1. `chr(0)` 返回什么？
>    - 空字符，不换行？
> 2. char string representation (`__repr__()`) 和 printed representation (`__str()__`) 的区别？
>    - string 表示包含非显示字符？
>    - `__repr__()` 返回对象字符串表示，力求准确、无歧义
>    - `__str__()` 将对象转换为易读字符串输出到 stdout，不显示引号，且转义字符可能被实际效果代替，如换行符变成实际换行
> 3. 如下代码输出什么？
>    ```python
>    >>> chr(0)
>    空
>    '\x00'
>    >>> print(chr(0))
>    空
>    '\x00'
>    >>> "this is a test" + chr(0) + "string"
>    "this is a teststring"
>    'this is\x00string'
>    >>> print("this is a test" + chr(0) + "string")
>    "this is a teststring"
>    ```

2. **Unicode Encoding**

Encoding: character -> a seq of bytes

直接用 Unicode codepoints 训练 tokenizer 不务实，词表可能非常大（150k 项）且稀疏（大部分少见），所以通常用 Unicode Encoding 替代，将 Unicode Character 转换为一系列 bytes，如 UTF-8。

> Python: `encode()`, `decode()`, `list()`

```python
>>> test_string = "hello! こんにちは!"
>>> utf8_encoded = test_string.encode("utf-8")
>>> print(utf8_encoded)
b'hello! \xe3\x81\x93\xe3\x82\x93\xe3\x81\xab\xe3\x81\xa1\xe3\x81\xaf!'
>>> print(type(utf8_encoded))
<class 'bytes'>
>>> # Get the byte values for the encoded string (integers from 0 to 255).
>>> list(utf8_encoded)
[104, 101, 108, 108, 111, 33, 32, 227, 129, 147, 227, 130, 147, 227, 129, 171, 227, 129,
161, 227, 129, 175, 33]
>>> # One byte does not necessarily correspond to one Unicode character!
>>> print(len(test_string))
13
>>> print(len(utf8_encoded))
23
>>> print(utf8_encoded.decode("utf-8"))
hello! こんにちは!
```

**Problem：**

> 1. 为什么用 UTF-8 编码字节，而非 UTF-16、UTF-32？
>    - UTF-8 更短、表示的字符更少，更短意味着内存用量更少、词表（大小）更小，表示的字符更少意味着更稠密、词表（个数）更小。序列越短，LLM 性能越好。
>    - 为什么 UTF-8 更短？因为保留位更少？
> 2. 下列代码错在哪
>    ```python
>    def decode_utf8_bytes_to_str_wrong(bytestring: bytes):
>        return "".join([bytes([b]).decode("utf-8") for b in bytestring])
>    >>> decode_utf8_bytes_to_str_wrong("hello".encode("utf-8"))
>    'hello'
>    ```
>    - UTF-8 下，会将单个 char 表示为 byte sequence。错在用 byte seq 去 encode，但用单个 byte 去 decode。
> 3. 给出包含两个 bytes 的序列，不能表示为任何 Unicode character。
>    - `[231, 137]`，"牛"前两个字节

3. **Subword Tokenization**

| | Pros | Cons |
|---|---|---|
| byte-level | 能表示一切 | 超长输入序列，拖慢模型训练；增加了 long-term dependencies on data |
| word-level | 短序列；语义强 | 超出词表表示范围 |
| subword | trade-off：用词表大小换取输入序列压缩 | |

按 byte pair 出现频率补充词表，从而压缩输入序列（用单个 subword unit 表示高频词汇）。

4. **BPE Tokenizer Training**

   1. **步骤**

      1. **Vocabulary initialization**：简单初始化为 256 个 byte value -> integer 映射，以及 special string -> token 映射
         - Tokenizer vocabulary：bytestring -> integer ID 的一一映射

      2. **Pre-tokenization**：将 input 转换为 pre-tokens，将 pre-tokens 表示为 UTF-8 byte sequence
         - 主逻辑：统计相邻出现的 bytes，合并高频 byte pair
         - 问题
           - 标点问题（e.g. `dog!` vs. `dog.`）
         - 方法
           - 按空格分割的 pre-tokenizer
           - regex-based pre-tokenizer
             - *PAT = r"""'(?:[sdmt]|ll|ve|re)| ?\p{L}+| ?\p{N}+| ?[^\s\p{L}\p{N}]+|\s+(?!\S)|\s+"""*
           - 用 `re.finditer` 而非 `re.findall`，避免保存 pre-tokenized words
         - 示例
           ```python
           # '(?:[sdmt]|ll|ve|re) 匹配 '
           # ?\p{L}+ 匹配可选的空格后跟一个或多个字母（Unicode字母），也可以匹配没有空格开头的字母
           # ?\p{N}+ 匹配选的空格后跟一个或多个数字（Unicode数字）
           # ?[^\s\p{L}\p{N}]+ 匹配可选的空格后跟一个或多个既不是空白、也不是字母、也不是数字的字符。这包括标点符号、符号等。
           # \s+(?!\S) 匹配一个或多个空白字符，但要求后面不能跟着非空白字符。
           # \s+ 匹配一个或多个空白字符。
           >>> PAT = r"""'(?:[sdmt]|ll|ve|re)| ?\p{L}+| ?\p{N}+| ?[^\s\p{L}\p{N}]+|\s+(?!\S)|\s+"""
           
           >>> # requires `regex` package
           >>> import regex as re
           >>> re.findall(PAT, "some text that i'll pre-tokenize")
           ['some', ' text', ' that', ' i', "'ll", ' pre', '-', 'tokenize']
           ```

      3. **Compute BPE merges**：
         - high level：
           - BPE 算法迭代式地对每个 byte pair 计数、定义最高频的 byte pair，加入词表，用新合并的 token 替换 byte pair 出现的地方。
           - 考虑 BPE 训练效率，不考虑跨 pre-token 边界的 byte pair。
           - 最终，词表个数 = 初始词表个数（256） + 训练期间 BPE 合并操作执行次数。
           - byte pair 频率相等时，倾向选择词典序大的。

      4. **Special tokens**：一些特殊 strings 作为不应被分割的 special token 加入词表，如行尾 `<|endoftext|>`。

   2. **示例**

      1. **Corpus（语料库）**
         - The vocabulary has a special token `<|endoftext|>`
         ```yaml
         low low low low low
         lower lower widest widest widest
         newest newest newest newest newest newest
         ```

      2. **Pre-tokenization**
         - *{low: 5, lower: 2, widest: 3, newest: 6}*

      3. **Merge**

         > *dict[tuple[bytes], int]*

         ```yaml
         1 round,
         {lo: 7, ow: 7, we: 8, er: 2, wi: 3, id: 3, de: 3, es: 9, st: 9, ne: 6, ew: 6}
         {lo: 7, ow: 7, we: 8, er: 2, wi: 3, id: 3, de: 3, es: 9, st: 9, ne: 6, ew: 6}
         {(l,o,w): 5, (l,o,w,e,r): 2, (w,i,d,e,st): 3, (n,e,w,e,st): 6}
         2 round,
         {lo: 7, ow: 7, we: 8, er: 2, wi: 3, id: 3, de: 3, est: 9, ne: 6, ew: 6}
         {(l,o,w): 5, (l,o,w,e,r): 2, (w,i,d,est): 3, (n,e,w,est): 6}
         3 round,
         {lo: 7, ow: 7, we: 2, er: 2, wi: 3, id: 3, dest: 3, west: 6, ne: 6, ew: 6}
         {lo: 7, ow: 7, we: 2, er: 2, wi: 3, id: 3, dest: 3, west: 6, ne: 6, ew: 6}
         {(l,ow): 5, (l,ow,e,r): 2, (w,i,d,est): 3, (n,e,w,est): 6}
         4 round,
         {low: 7, owe: 2, er: 2, wi: 3, id: 3, dest: 3, west: 6, ne: 6, ew: 6}
         {(low): 5, (low,e,r): 2, (w,i,d,est): 3, (n,e,w,est): 6}
         5 round,
         {lowe: 2, er: 2, wi: 3, id: 3, dest: 3, west: 6, ne: 6, ew: 6}
         {lowe: 2, er: 2, wi: 3, id: 3, dest: 3, west: 6, ne: 6, ew: 6}
         {(low): 5, (low,e,r): 2, (w,i,d,est): 3, (n,e,west): 6}
         6 round,
         {lowe: 2, er: 2, wi: 3, id: 3, dest: 3, ewest: 6, ne: 6}
         {lowe: 2, er: 2, wi: 3, id: 3, dest: 3, ewest: 6, ne: 6}
         {(low): 5, (low,e,r): 2, (w,i,d,est): 3, (ne,west): 6}
         7 round,
         {lowe: 2, er: 2, wi: 3, id: 3, dest: 3, newest: 6}
         {(low): 5, (low,e,r): 2, (w,i,d,est): 3, (newest): 6}
         8 round,
         {lowe: 2, er: 2, wi: 3, id: 3, dest: 3}
         {lowe: 2, er: 2, wi: 3, id: 3, dest: 3}
         {(low): 5, (low,e,r): 2, (wi,d,est): 3, (newest): 6}
         9 round,
         {lowe: 2, er: 2, wid: 3, dest: 3}
         {lowe: 2, er: 2, wid: 3, dest: 3}
         {(low): 5, (low,e,r): 2, (wid,est): 3, (newest): 6}
         10 round,
         {lowe: 2, er: 2, widest: 3}
         {(low): 5, (low,e,r): 2, (widest): 3, (newest): 6}
         11 round,
         {lowe: 2, er: 2}
         {(low): 5, (lowe,r): 2, (widest): 3, (newest): 6}
         12 round,
         {lower: 2}
         {(low): 5, (lower): 2, (widest): 3, (newest): 6}
         ```

         - sequence of merges: `st, est, ow, low, west, ne, newest, wi, wid, widest, lowe, lower`

5. **Experimental with BPE Tokenizer Training**

   1. **并行 pre-tokenization**
      - 用 `multiprocessing` 库
      - 在 special token 处切分语料库，确保边界一致

   2. **Pre-tokenization 前移除 Special tokens**
      - 用 `re.split` 和 `"|".join(special_tokens)` 作为分界符，而非用 `re.escape`（`|` 本身也可能作为 special token）
        - *test_train_bpe_special_tokens*

   3. **优化 merging step**
      - 每轮都通过遍历 byte pairs 来识别最高频 pair 很慢，由于每轮只有被合并的 pair count 会改变，可以通过索引 pair count、增量更新 counts 来提速
        - index: count -> pair
      - merging step 无法并行化
        - **优化建议**
          - **Profiling**
            - 用 profiling 工具找瓶颈。例如，cProfile, scalene。
          - **Downscaling**
            - 先用小数据集、小模型跑通功能。例如，debug dataset。
        - Problems
          - TBC

6. **BPE Tokenizer: Encoding and Decoding**

