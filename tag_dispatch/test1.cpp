#include <iostream>
#include <type_traits> // 用于类型判断的标准库

// 1. 定义标签类（tag classes）
// 这些空类仅用于标识不同的类型类别，没有实际数据或方法
struct integer_tag {};    // 整数类型的标签
struct floating_tag {};   // 浮点类型的标签

// 2. 编写辅助函数，用于根据类型获取对应的标签
// 对于整数类型，返回integer_tag
template <typename T>
typename std::enable_if<std::is_integral<T>::value, integer_tag>::type
get_tag() {
    return integer_tag();
}

// 对于浮点类型，返回floating_tag
template <typename T>
typename std::enable_if<std::is_floating_point<T>::value, floating_tag>::type
get_tag() {
    return floating_tag();
}

// 3. 编写带标签的重载函数（核心实现）
// 处理整数类型的实现
template <typename T>
void process_impl(T value, integer_tag) {
    std::cout << "处理整数: " << value << std::endl;
    std::cout << "  特性: 整数没有小数部分，精度固定" << std::endl;
    std::cout << "  示例操作: 计算平方 = " << value * value << std::endl;
}

// 处理浮点类型的实现
template <typename T>
void process_impl(T value, floating_tag) {
    std::cout << "处理浮点数: " << value << std::endl;
    std::cout << "  特性: 浮点数有小数部分，精度可变" << std::endl;
    std::cout << "  示例操作: 计算平方根 = " << sqrt(value) << std::endl;
}

// 4. 对外提供的统一接口函数
// 这个函数会根据输入类型自动选择合适的实现
template <typename T>
void process(T value) {
    // 获取与类型T对应的标签
    auto tag = get_tag<T>();
    // 调用带标签的重载函数，编译器会自动匹配正确的版本
    process_impl(value, tag);
}

int main() {
    // 测试整数类型
    int a = 42;
    std::cout << "=== 处理int类型 ===" << std::endl;
    process(a);
    
    // 测试长整数类型
    long b = 123456789;
    std::cout << "\n=== 处理long类型 ===" << std::endl;
    process(b);
    
    // 测试单精度浮点类型
    float c = 3.14f;
    std::cout << "\n=== 处理float类型 ===" << std::endl;
    process(c);
    
    // 测试双精度浮点类型
    double d = 2.71828;
    std::cout << "\n=== 处理double类型 ===" << std::endl;
    process(d);
    
    return 0;
}
