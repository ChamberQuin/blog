# Byte code
## Class
### Class文件格式

| 类型 | 名称 |
| --- | --- |
| u4 | magic *CAFEBABE* |
| u2 | minor_version |
| u2 | major_version |
| u2 | constant_pool_count |
| cp_info | constant_pool |
| u2 | access_flags |
| u2 | this_class |
| u2 | super_class |
| u2 | interfaces_count |
| u2 | interfaces |
| u2 | fields_count |
| field_info | fields |
| u2 | methods_count |
| method_info | methods  |
| u2 | attributes_count |
| attribute_info | attributes |

### Constant pool
1. 特点
	* 与其他项目关联最多
	* 占Class文件空间最大
	* 0保留给this，计数从1开始（1~21，u2类型）

2. 分类
	* 字面量 Literal
		* 字符串
		* final常量等
	* 符号引用 Symbolic References
		* 类和接口的全限定名 Fully Qualified Name
		* 字段的名称和描述符 Field Descriptor
		* 方法的名称和描述符 Method Descriptor
	
	> 执行Javac时在VM加载Class文件时动态连接，所以Class文件中不保存方法、字段的最终内存布局信息。
	> VM运行时，要从常量池获取对应符号引用，再在类创建/运行时解析、翻译到具体的内存地址中。

3. 常量池项目类型

	| 类型 | 标识 | 描述 |
	| --- | --- | --- |
	| CONSTANT_Utf8_info | 1 | utf8编码的字符串 |
	| CONSTANT_Integer_info | 3 | int literal |
	| CONSTANT_Float_info | 4 | float literal |
	| CONSTANT_Long_info | 5 | long literal |
	| CONSTANT_Double_info | 6 | double literal |
	| CONSTANT_Class_info | 7 | 类或接口的符号引用 |
	| CONSTANT_String_info | 8 | string literal |
	| CONSTANT_Fieldref_info | 9 | 字段的符号引用 |
	| CONSTANT_Methodref_info | 10 | 类中方法的符号引用 |
	| CONSTANT_InterfaceMethodref_info | 11 | 接口中方法的符号引用 |
	| CONSTANT_NameAndType_info | 12 | 字段或方法的部分符号引用 |
	| CONSTANT_MethodHandle_info | 15 | 表示方法句柄 |
	| CONSTANT_MethodType_info | 16 | 标识方法类型 |
	| CONSTANT_InvokeDynamic_info | 18 | 表示一个动态方法的调用点 |

	1. CONSTANT_Class_info型常量的结构
	
		| 类型 | 名称 | 数量 |
		| --- | --- | --- |
		| u1 | tag | 1 |
		| u2 | name_index | 1 |

		> name_index是一个索引值，指向常量池中一个CONSTANT_Utf8_info型常量，表示这个类/接口的全限定名
		
	2. CONSTANT_Utf8_info型常量的结构

		| 类型 | 名称 | 数量 |
		| --- | --- | --- |
		| u1 | tag | 1 |
		| u2 | length | 1 |
		| u1 | bytes | length |

		> length说明UTF-8字符串长度，byte为使用UTF-8缩略编码表示的字符串。
		> 
		> Class文件中的方法、字段等都要引用CONSTANT_Utf8_info型常量来描述，所以length的最大长度也就是Java中方法、字段名的最大长度，即u2的MAX_VALUE=65535（64K）。
			
	4. UTF-8缩略编码
		* 从'\u0001'~'\u007f'间的字符（1~127）使用1个Byte
		* 从'\u0080'~'\u07ff'间的字符使用2个Byte
		* 从'\u0800'~'\uffff'间的字符使用4个Byte（与普通UTF-8编码相同）
	
	6. 常量项总表
	
		![](media/15314650113150.jpg)
	
5. 分析工具
		
	> javap -v *.class

### 访问标志

识别类/接口层次的访问信息，共16项，当前定义了8项，剩余一律为`0`

| 名称 | 含义 |
| --- | --- |
| ACC_PUBLIC |  |
| ACC_FINAL |  |
| ACC_SUPER | 是否允许使用invokespecial字节码指令的新语义，JDK1.0.2后默认true |
| ACC_INTERFACE |  |
| ACC_ABSTRACGT |  |
| ACC_SYNTHETIC | 标识类并非用户产生 |
| ACC_ANNOTATION |   |
| ACC_ENUM |  |

### 类索引、父类索引、接口索引集合
this_class(u2), super_class(u2), interfaces(多个u2)共同确定类的继承关系。

### 字段表集合
field_info用于描述接口/类中声明的变量，包括类/实例级的变量，不包括方法内的局部变量。

1. 内容

	* 字段作用域 public/private/protected
	* 是实例变量或类变量 static
	* 可变性 final
	* 并发可见性 volatile（是否强制读写主存）
	* 可否被序列化 transient
	* 字段数据类型 基本类型/对象/数组
	* 字段名

2. 结构
		
	| 类型 | 名称 | 数量 |
	| --- | --- | --- |
	| u2 | access_flags | 1 |
	| u2 | name_index 字段简单名称 | 1  |
	| u2 | descriptor_index 字段和方法的描述符 | 1 |
	| u2 | attributes_count | 1 |
	| attribute_info | attributes | attributes_count |

	> 全限定名：org/fenixsoft/clazz/TestClass;

	> 简单名称：没有类型和参数修饰的方法或字段名称
		eg:void inc() -> inc

	> 描述符：描述字段的数据类型、方法的参数列表、返回值
		eg: java.lang.String toString() -> ()Ljava/lang/String; 
		eg: int indexOf(char[] source, int sourceOffset, int sourceCount, char[] target, int targetOffset, int targetCount, int fromIndex) -> ([CII[CII)I)

3. 描述符标识字符含义

	| 标识字符 | 含义 |
	| --- | --- |
	| B | byte |
	| C | char |
	| D | double |
	| F | float  |
	| I | int |
	| J | long |
	| S | short |
	| Z | boolean |
	| V | void |
	| L | 对象 |
	| [ | 数组 |

### 方法表集合
方法表和字段表几乎一致，结构相同，仅在访问标志和属性表集合的可选项中有区别。

* volatile transient不能修饰method
* synchronized native strictfp abstract能修饰method

**override一个方法，要求有相同的简单名称，和不同的特征签名**

特征签名：方法中各参数在常量池中的字段符号引用的集合
> 返回值不包含在内（因此Java中无法仅依靠返回值override）

### 属性表
attribute_info用于描述某些场景的专有信息，Class文件、字段表、方法表都可以有自己的属性表集合。

1. 预定义的属性

	| 名称 | 含义 |
	| --- | --- |
	| Code | 字节码指令 |
	| ConstantValue | final定义的常量值 |
	| Deprecated |  |
	| Exceptions |  |
	| EnclosingMethod | 仅当类为局部类或匿名类时才有，用于标识类所在的外围方法 |
	| InnerClass | 内部类列表 |
	| LineNumberTable | 源码行号与字节码指令的对应关系 |
	| LocalVariableTable | 方法的局部变量描述 |
	| StackMapTable | JDK1.6新增属性，供新的类型检查验证器检查和处理目标方法的局部变量和操作数栈所需的类型是否匹配 |
	| Signature | JDK1.5新增属性，用于支持泛型情况下的方法签名。由于Java的泛型采用擦除法实现，为了避免类型信息被擦除后导致签名混乱，需要这个属性记录泛型中的相关信息 |
	| SourceFile |  |
	| SourceDebugExtension | JDK1.6新增属性，存储额外调试信息，如JSP文件调用时无法通过Java堆栈定位JSP行号，JSR-45规范为非Java语言编写的需要编译为字节码并运行在JVM中的程序提供了一个进行调试的标准机制  |
	| Synthetic | 标识方法或字段为编译器自动生成的 |
	| LocalVariableTypeTable | JDK1.5新增属性，使用特征签名代替描述符，为了引入泛型语法后能描述泛型参数化类型。 |
	| RuntimeVisibleAnnotations | JDK1.5新增属性，为动态注解提供支持，用于指明哪些注解是运行时（即进行反射调用时）可见 |
	| RuntimeInvisibleAnnotations | 同上，但是不可见 |
	| AnnotationDefault | JDK1.5新增属性，记录注解类元素默认值 |
	| BootstrapMethods | JDK1.7新增属性，用于保存invodedynamic指令引用的引导方法限定符  |

2. 属性表结构

	| 类型 | 名称 | 数量 |
	| --- | --- | --- |
	| u2 | attribute_name_index | 1 |
	| u4 | attribute_length | 1 |
	| u1 | info | attribute_length |
 
3. Code
	
	| 类型 | 名称 | 含义 |
	| --- | --- | --- |
	| u2 | attribute_name_index | 属性名称 |
	| u4 | attribute_length | 属性值长度 |
	| u2 | max_stack | 操作数栈最大深度，VM据此分配Frame中操作栈深度 |
	| u2 | max_locals | 局部变量所需的存储空间，单位是slot。 |
	| u4 | code_length | 字节码长度 |
	| u1 | code | 字节码指令，每个指令是单字节 |
	| u2 | exception_table_length |  |
	| exception_info | exception_table | 显式异常处理表集合 |
	| u2 | attributes_count |  |
	| attribute_info | attributes |  |

	1. Slot
		* Slot是VM为局部变量分配内存所使用的最小单位。
			* byte/char/float/int/short/boolean/returnAddress等长度<=32位的数据类型，每个局部变量占1个slot；
			* double/long等64位数据类型，每个局部变量占2个slot;
			* 方法参数`(含this)`/显示异常处理器参数/方法体中定义的局部变量也存在局部变量中。
		* 由于局部变量表中的slot可重用，当代码执行超出局部变量作用域时，相应slot可以被其他局部变量使用。
	2. 字节码指令长度 code_length
		* u4范围2^32 - 1，但VM明确限制了方法不能超过2^16 - 1条字节码指令，实际使用u2长度，超出时javac会拒绝编译
		* 某些特殊情况可能超出，如编译复杂jsp时，某些jsp编译器会把jsp内容和页面输出归并在一个方法中，导致编译失败
	2. 字节码指令 code
		* VM根据code找出字节码对应的指令，并知道是否需要跟随参数，以及如何理解参数
		* u1范围0x00~0xFF（0~255）条指令，具体可查阅`虚拟机字节码指令表`
	3. 显式异常表 exception_table
	
		| 类型 | 名称 | 数量 |
		| --- | --- | --- |
		| u2 | start_pc | 1 |
		| u2 | end_pc | 1 |
		| u2 | handler_pc | 1 |
		| u2 | catch_type | 1 |

		* Java使用**异常表**而非简单的跳转命令来实现异常及finally处理机制
			* JDK1.4.2之前的javac编译器采用`jsr`和`ret`指令实现finally语句，但之后改为编译器自动在每段可能分支路径后将finally语句冗余生成一遍来实现语义，JDK1.7中已经完全禁止Class文件中出现上述指令，VM会在**类加载的字节码校验阶段**抛异常

4. Exceptions属性
	列出方法中可能抛的受查异常（Checked Exceptions，即方法描述时`throws`列举的异常）

	1. 结构
		
		| 类型 | 名称 | 数量 |
		| --- | --- | --- |
		| u2 | attribute_name_index | 1 |
		| u4 | attribute_length | 1 |
		| u2 | number_of_exceptions | 1 |
		| u2 | exception_index_table | number_of_exceptions |

		* 每个`Checked Exception`用一个`exception_index_table`项表示，它指向常量池中`CONSTANT_Class_info`型常量的索引，代表该异常的类型

5. LineNumberTable属性
	
	描述Java源码行号与字节码行号间的映射。
		* 非必需，但会默认生成到Class文件中
		* javac -g:none/-g:lines来取消/生成该项信息
		* 取消后堆栈中没行号，也无法按行设置断点

6. LocalVariableTable属性
	
	描述栈帧中局部变量表中的变量与Java源码中定义的变量间的关系。
	* 非必需，但会默认生成到Class文件中
	* javac -g:none/-g:vars来取消/生成该项信息
	* 取消后他人引用方法时，会丢失所有参数名称，IDE将使用arg0等占位符代替原有参数名，调试期也无法根据参数名从上下文获取参数值

	1. LocalVariableTable属性结构
			
		| 类型 | 名称 | 数量 |
		| --- | --- | --- |
		| u2 | attribute_name_index | 1 |
		| u4 | attribute_length | 1 |
		| u2 | local_variable_table_length | 1 |
		| lcoal_variable_info | local_variable_table | local_variable_table_length  |

	2. local_variable_info项目结构
		
		| 类型 | 名称 | 数量 | 含义 |
		| --- | --- | --- | --- |
		| u2 | start_pc | 1 | 局部变量生命周期开始的字节码偏移量 |
		| u2 | length | 1 | 局部变量生命周期的作用范围长度 |
		| u2 | name_index | 1 | 局部变量名称 |
		| u2 | descriptor_index | 1 | 局部变量描述符 |
		| u2 | index | 1 | 局部变量在栈帧局部变量表中Slot的位置 |
		
		> 变量数据类型为64位时，占用2个Slot: index, index + 1

7. SourceFile属性

	记录生成Class文件的源码文件名称。
	
	* 定长
	* javac -g:none/-g:source
	* 特殊情况（如内部类）的类名和文件名不一致
	* 取消后，抛异常时堆栈中不显示出错代码所属的文件名

8. ConstantValue属性
	
	通知虚拟机自动为静态变量赋值。
	
	* 变量赋值方式和时刻
		* 非static变量（实例变量）赋值是在实例构造器<init>方法中
		* static类变量赋值
			* 类构造器<clinit>方法中
			* 使用ConstantValue属性
	* Sun Javac编译器的做法
		* final static的基本类型/String变量，则生成ConstantValue进行初始化
		* 没被final修饰/不是基本类型或String，则在<clinit>方法中进行初始化

9. InnerClasses属性

	记录内部类与宿主类间的关联。
	
10. Deprecated和Synthetic属性

	属于标识类型的布尔属性。
	
	> JDK1.5后可以设置访问标志ACC_SYNTHETIC标识类、字段、方法是便以其自动产生的。
	> 所有字段都应至少设置`Synthetic属性和ACC_SYNTHETIC标志位`中的一项，只除了实例构造器`<init>`和类构造器`<clinit>`。

11. StackMapTable属性
	
	JDK1.6后加入规范，复杂的变长属性，会在虚拟机类加载的字节码校验阶段被新类型检查验证器`Type Checker`使用，目的在于替代以前比较耗性能的基于数据流分析的类型推导验证器。
	包含0~n个`Stack Map Frames`，每个代表一个字节码偏移量，用于表示执行到该字节码时局部变量表和操作数栈的验证类型。`Type Checker`会通过检查目标方法的局部变量和操作数栈所需的类型来确定字节码指令是否符合逻辑约束。
	
	1. 结构

		| 类型 | 名称 | 数量 |
		| --- | --- | --- |
		| u2 | attribute_name_index | 1 |
		| u4 | attribute_length | 1 |
		| u2 | number_of_entries | 1 |
		| stack_map_frame | stack_map_frame entries | number_of_entries |
		
	2. 约束
	
		规范SE7规定
		* `version >= 50.0的Class文件`中，如果Code没有附带`StackMapTable属性`，则意味着它带有一个隐式的`StackMap属性`，作用等同于`number_of_entries=0的StackMapTable属性`。
		* 一个`Code属性`最多有一个`StackMapTable属性`，否则抛`ClassFormatError`


