//
//  NSObject+KVO.m
//  ComponentDemo
//
//  Created by yao wang on 2018/6/25.
//  Copyright © 2018年 yao wang. All rights reserved.
//

#import "NSObject+WYKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSString+Property.h"
/******************************************************************************************
attribute((always_inline))的意思是强制内联，所有加了attribute((always_inline))的函数再被调用时不会被编译成函数调用而是直接扩展到调用函数体内，比如我定义了函数
attribute((always_inline))
void a()和
void b()｛
 a();
｝
b调用a函数的汇编代码不会是跳转到a执行，而是a函数的代码直接在b内成为b的一部分。
 
 
 获取类定义的方法有三个：objc_lookUpClass, objc_getClass和objc_getRequiredClass。如果类在运行时未注册，则objc_lookUpClass会返回nil，而objc_getClass会调用类处理回调，并再次确认类是否注册，如果确认未注册，再返回nil。而objc_getRequiredClass函数的操作与objc_getClass相同，只不过如果没有找到类，则会杀死进程。
 
 
 objc_allocateClassPair(Class _Nullable superclass, const char * _Nonnull name, size_t extraBytes)
 
 
 
 id objc_getAssociatedObject(id object, const void *key);
 void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
 @selector(categoryProperty) 也就是参数中的 key，其实可以使用静态指针 static void * 类型的参数来代替，不过在这里，推荐使用 @selector(categoryProperty) 作为 key 传入。因为这种方法省略了声明参数的代码，并且能很好地保证 key 的唯一性。
 
 
 不同的 objc_AssociationPolicy 对应了不通的属性修饰符：
 objc_AssociationPolicy    modifier
 OBJC_ASSOCIATION_ASSIGN    assign
 OBJC_ASSOCIATION_RETAIN_NONATOMIC    nonatomic, strong
 OBJC_ASSOCIATION_COPY_NONATOMIC    nonatomic, copy
 OBJC_ASSOCIATION_RETAIN    atomic, strong
 OBJC_ASSOCIATION_COPY    atomic, copy

******************************************************************************************/

#define force_inline __inline__ __attribute__((always_inline))

NSString *const kWYKVOClassPrefix = @"WYKVO_";
static char const * kObservers= "WYOBSERVERS";

@interface WYObserverInfo : NSObject

@property (nonatomic, copy) NSString *observerName;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) WYObserverBlock block;

@end

@implementation WYObserverInfo

- (instancetype)initWithObserver:(NSString *)observer key:(NSString *)key block:(WYObserverBlock)block
{
    self = [super init];
    if (self) {
        self.observerName = observer;
        self.key = key;
        self.block = block;
    }
    return self;
}


@end



/**
 获取类的setter方法名
 
 @param key 属性名字
 @return setter方法名
 */
static force_inline NSString *setterNameByKey(NSString *key)
{
    if (key.length <= 0) return nil;
    
    NSString *firstLetter = [[key substringToIndex:1] uppercaseString];
    NSString *remainedLetters = [key substringFromIndex:1];
    NSString *setter = [NSString stringWithFormat:@"set%@%@:",firstLetter, remainedLetters];
    return setter;
}

static NSString * getterForSetter(NSString *setter)
{
    if (setter.length <=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    
    // remove 'set' at the begining and ':' at the end
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *key = [setter substringWithRange:range];
    
    // lower case the first letter
    NSString *firstLetter = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                       withString:firstLetter];
    return key;
}

static Class kvo_class(id self, SEL _cmd)
{
    return class_getSuperclass(object_getClass(self));
}


#pragma mark overrid
static void kvo_setter(id self, SEL _cmd, id newValue)
{
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *key = getterForSetter(setterName);
    if (!key) {
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have setter %@", self, setterName];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
        return;
    }

    id oldValue = [self valueForKey:key];
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    // cast our pointer so the compiler won't complain
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;

    // call super's setter, which is original class's setter method
    objc_msgSendSuperCasted(&superClazz, _cmd, newValue);

    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    for (WYObserverInfo *temp in observers) {
        if ([temp.key isEqualToString:key]) {
            temp.block(self, key, oldValue, newValue);
        }
    }
}

static void kvo_base_setter(id self, SEL _cmd, int newValue)
{
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *key = getterForSetter(setterName);
    if (!key) {
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have setter %@", self, setterName];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
        return;
    }
    
    int oldValue = [[self valueForKey:key] intValue];
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    // cast our pointer so the compiler won't complain
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
    
    // call super's setter, which is original class's setter method
    objc_msgSendSuperCasted(&superClazz, _cmd, [NSNumber numberWithInteger:newValue]);
    
    NSMutableArray *observers = objc_getAssociatedObject(self,kObservers);
    for (WYObserverInfo *temp in observers) {
        if ([temp.key isEqualToString:key]) {
            temp.block(self, key, [NSNumber numberWithInt:oldValue] , [NSNumber numberWithInt:newValue]);
        }
    }
}


@implementation NSObject (WYKVO)

/**
 添加观察者
 
 @param observer 观察者对象
 @param key key
 @param block 属性变化时返回的block
 */
- (void)wy_addObserver:(NSObject *)observer forKey:(NSString *)key changeBlock:(WYObserverBlock)block
{
    
//  1:检查对象类有没有相应的setter方法，如果没有就抛出异常
    SEL setterSelector = NSSelectorFromString(setterNameByKey(key));
    Method setterMethod = class_getInstanceMethod([self class], setterSelector);

    if (!setterMethod) {
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have a setter for key %@", self, key];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];

        return;
    }

//  2、检查isa指向 的类是不是一个KVO类，如果不是，新建一个继承原来类的子类，并把 isa 指向这个新建的子类；
    Class clas = object_getClass(self);
    NSString *className = NSStringFromClass(clas);

    //如果该类不是一个KVO类，就创建一个KVO子类
    if (![className hasPrefix:kWYKVOClassPrefix]) {
        NSString *kvoClassName = [kWYKVOClassPrefix stringByAppendingString:className];
        Class kvoClass = NSClassFromString(kvoClassName);

        if (!kvoClass) {
            //定义一个子类
            kvoClass = objc_allocateClassPair(clas, kvoClassName.UTF8String, 0);
        }
        Method method = class_getInstanceMethod(kvoClass, @selector(class));
        const char *types = method_getTypeEncoding(method);
        
//        const char * propertyName = key.UTF8String;
//        objc_property_t t = class_getProperty(clas, propertyName);
//        const char *attribute = property_getAttributes(t);

//        class_replaceProperty(clas, propertyName, attribute, <#unsigned int attributeCount#>)

        
        class_addMethod(kvoClass, @selector(class), (IMP)kvo_class, types);
        objc_registerClassPair(kvoClass);

        //修改被观察者的isa指针,指向自定义的类
        object_setClass(self, kvoClass);
        clas = kvoClass;
    }

//  3、检查对象的KVO类是否重写过这个setter方法，如果没有，就重写setter方法
    if (![self hasSelector:setterSelector]) {
        const char *types = method_getTypeEncoding(setterMethod);

        //给这个派生类添加一个set 方法  并且指向kvo_setter这个方法 也就是说没次修改属性时 在调用set方法时 都会调用这个方法
        BOOL isBasicType = [self isBasicDataTypeOfProperty:key inClass:clas];
        if (isBasicType) {
//            int value = [[self valueForKey:key] intValue];
//            Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
//            object_setIvar(clas, ivar, [NSNumber numberWithInt:value]);
            
//            const char * propertyName = key.UTF8String;
//            objc_property_t t = class_getProperty(clas, propertyName);
//            const char *attribute = property_getAttributes(t);

//            class_replaceProperty(Class _Nullable cls, const char * _Nonnull name,
//                                  const objc_property_attribute_t * _Nullable attributes,
//                                  unsigned int attributeCount)
            
            class_addMethod(clas, setterSelector, (IMP)kvo_base_setter, types);
//            class_addMethod(clas, setterSelector, (IMP)kvo_setter, types);

        }else{
            class_addMethod(clas, setterSelector, (IMP)kvo_setter, types);
        }
    }


    //      4、添加观察者
    WYObserverInfo *info = [[WYObserverInfo alloc]initWithObserver:observer.description key:key block:block];
    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    if (!observers) {
        observers = [NSMutableArray array];
        //动态绑定属性
        objc_setAssociatedObject(self, kObservers, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observers addObject:info];
}


/**
 删除观察者

 @param observer 注册的观察者
 @param key 观察者key
 */
- (void)wy_removeObserver:(NSObject *)observer forKey:(NSString *)key
{
    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    WYObserverInfo *info;
    for (WYObserverInfo *tempInfo in observers) {
        if ([tempInfo.observerName isEqualToString:observer.description] && [tempInfo.key isEqual:key]) {
            info = tempInfo;
            break;
        }
    }
    if (info) {
        [observers removeObject:info];
    }else{
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ does not regist key %@", observer.description, key] userInfo:nil];
    }
}

/**
 移除所有观察者
 */
- (void)wy_removeAllObservers
{
    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    [observers removeAllObjects];
}

/**
 移除指定观察者

 @param observer 指定的观察者
 */
- (void)wy_removeObserver:(NSObject *)observer
{
    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    NSMutableArray *removeItems = [NSMutableArray array];
    for (WYObserverInfo *tempInfo in observers) {
        if ([tempInfo.observerName isEqualToString:observer.description]) {
            [removeItems addObject:tempInfo];
        }
    }
    if (removeItems.count) {
        [observers removeObjectsInArray:removeItems];
    }
}

/**
 重写setter方法

 @param value value
 @param key key
 */
- (void)wy_setValue:(NSString *)value forKey:(NSString *)key
{
    NSLog(@"KVO setValue forKey");
    id oldValue = [self valueForKey:key];
    [self wy_setValue:value forKey:key];
    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    for (WYObserverInfo *info in observers) {
        if ([info.key isEqualToString:key]) {
            info.block(self, key, oldValue, value);
        }
    }
}


- (BOOL)hasSelector:(SEL)selector
{
    Class clazz = object_getClass(self);
    unsigned int methodCount = 0;
    Method* methodList = class_copyMethodList(clazz, &methodCount);
    for (unsigned int i = 0; i < methodCount; i++) {
        SEL thisSelector = method_getName(methodList[i]);
        if (thisSelector == selector) {
            free(methodList);
            return YES;
        }
    }
    
    free(methodList);
    return NO;
}

-(BOOL)isBasicDataTypeOfProperty:(NSString *)key inClass:(Class)class
{
    const char * propertyName = key.UTF8String;
    
    objc_property_t t = class_getProperty(class, propertyName);
    
    const char *attribute = property_getAttributes(t);
    
    return [self isBasePropertyType:attribute];
}

- (BOOL)isBasePropertyType:(const char *)property_attr {
    BOOL isBaseType = NO;
    char t = property_attr[1];
    
    if (!strcmp(&t, @encode(int)) ||
        !strcmp(&t, @encode(short)) ||
        !strcmp(&t, @encode(long)) ||
        !strcmp(&t, @encode(long long)) ||
        !strcmp(&t, @encode(unsigned int)) ||
        !strcmp(&t, @encode(unsigned int)) ||
        !strcmp(&t, @encode(unsigned short)) ||
        !strcmp(&t, @encode(unsigned long)) ||
        !strcmp(&t, @encode(unsigned long long)) ||
        !strcmp(&t, @encode(float)) ||
        !strcmp(&t, @encode(double)) ||
        !strcmp(&t, @encode(_Bool)) ||
        !strcmp(&t, @encode(bool))){
        isBaseType = YES;
    }
    
    return isBaseType;
}




@end

