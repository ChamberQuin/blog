# Java 类加载

## 双亲委派

从 Java 虚拟机的角度来看,只存在两种不同的类加载器:

* 启动类加载器(Bootstrap ClassLoader), 由 C++语言实现,是虚拟机自身的一部分.
* 其他的类加载器,都是由 Java 实现,在虚拟机的外部,并且全部继承自java.lang.ClassLoader

在 Java 内部,绝大部分的程序都会使用 Java 内部提供的默认加载器.

1. 启动类加载器(Bootstrap ClassLoader)
	负责将$JAVA_HOME/lib或者 -Xbootclasspath 参数指定路径下面的文件(按照文件名识别,如 rt.jar) 加载到虚拟机内存中.启动类加载器无法直接被 java 代码引用,如果需要把加载请求委派给启动类加载器,直接返回null即可.

2. 扩展类加载器(Extension ClassLoader)
	负责加载$JAVA_HOME/lib/ext 目录中的文件,或者java.ext.dirs 系统变量所指定的路径的类库.

3. 应用程序类加载器(Application ClassLoader)
	一般是系统的默认加载器,比如用 main 方法启动就是用此类加载器,也就是说如果没有自定义过类加载器,同时它也是getSystemClassLoader() 的返回值.



