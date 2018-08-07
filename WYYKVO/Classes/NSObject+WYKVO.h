//
//  NSObject+KVO.h
//  ComponentDemo
//
//  Created by yao wang on 2018/6/25.
//  Copyright © 2018年 yao wang. All rights reserved.
//

#import <Foundation/Foundation.h>

//在Swift中存在Option类型，也就是使用？和！声明的变量。但是OC里面没有这个特征,因为在XCODE6.3之后出现新的关键词定义用于OC转SWIFT时候可以区分到底是什么类型
//
//__nullable && ___nonnull
//
//__nullable指代对象可以为NULL或者为NIL
//__nonnull指代对象不能为null
//当我们不遵循这一规则时，编译器就会给出警告。


//如果需要每个属性或每个方法都去指定nonnull和nullable，是一件非常繁琐的事。苹果为了减轻我们的工作量，专门提供了两个宏：NS_ASSUME_NONNULL_BEGIN和NS_ASSUME_NONNULL_END。在这两个宏之间的代码，所有简单指针对象都被假定为nonnull，因此我们只需要去指定那些nullable的指针。如下代码所示：
//
//NS_ASSUME_NONNULL_BEGIN
//@interface TestNullabilityClass ()
//@property (nonatomic, copy) NSArray * items;
//- (id)itemWithName:(nullable NSString *)name;
//@end
//NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

typedef void(^WYObserverBlock) (id observer,  NSString *key, id oldValue, id newValue);

@interface NSObject (WYKVO)
    
- (void)wy_addObserver:(NSObject *)observer forKey:(NSString *)key changeBlock:(WYObserverBlock)block;

- (void)wy_removeObserver:(NSObject *)observer forKey:(NSString *)key;

- (void)wy_removeAllObservers;

@end

NS_ASSUME_NONNULL_END
