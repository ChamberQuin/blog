[toc]

# 重要代码

# 概念
stack frame layout
stack memory layout
stack expansion 过程
hot split problem
Golang的内存安全机制

# runtime

runtime/stack.go

``` go

// Stack frame layout
//
// (x86)
// +------------------+
// | args from caller |
// +------------------+ <- frame->argp
// |  return address  |
// +------------------+
// |  caller's BP (*) | (*) if framepointer_enabled && varp < sp
// +------------------+ <- frame->varp
// |     locals       |
// +------------------+
// |  args to callee  |
// +------------------+ <- frame->sp
//
// (arm)
// +------------------+
// | args from caller |
// +------------------+ <- frame->argp
// | caller's retaddr |
// +------------------+ <- frame->varp
// |     locals       |
// +------------------+
// |  args to callee  |
// +------------------+
// |  return address  |
// +------------------+ <- frame->sp

```

``` go
package main

// 为了避免add帧尺寸为0，所以强行加入一个局部变量tmp
func add(a, b int64) (int64, int64) {
	var tmp int64 = 1
	tmp = tmp + a
	return a + b, a - b
}

func main() {
	var c int64 = 10
	var d int64 = 12
	add(c, d)
}
```

``` bash
$ GOOS=linux GOARCH=amd64 go tool compile -S -N -l main.go
```








