The key concepts in OOP are:

Classes and Objects: A class is a blueprint or a template that defines the attributes (data) and behaviors (methods) that an object of that class should have. An object is an instance of a class. Classes encapsulate data and related behaviors into a single unit.

Encapsulation: Encapsulation is the practice of bundling data and methods together within a class and restricting access to the internal data of an object from outside. It helps in achieving data hiding and abstraction, ensuring that the internal implementation details are hidden and only the necessary interface is exposed.

Inheritance: Inheritance is a mechanism that allows a class to inherit properties and behaviors from another class. The class that is being inherited from is called the base class or superclass, and the class that inherits from the base class is called the derived class or subclass. Inheritance promotes code reuse and allows the creation of hierarchical relationships between classes.

Polymorphism: Polymorphism refers to the ability of an object to take on multiple forms or have multiple behaviors. It allows objects of different classes to be treated as objects of a common superclass. Polymorphism is achieved through method overriding and method overloading.

Method Overriding: Method overriding occurs when a derived class provides its own implementation of a method that is already defined in the base class. The method in the derived class overrides the behavior of the method in the base class.

Method Overloading: Method overloading involves defining multiple methods in a class with the same name but different parameters. The appropriate method is selected based on the number, types, and order of the arguments passed during method invocation.

Abstraction: Abstraction is the process of representing complex real-world entities using simplified models. It focuses on the essential features of an object or a system while hiding the unnecessary details. Abstract classes and interfaces are used to define common behavior and enforce a contract that derived classes must adhere to.

_class and objects_


```py
class Car:
    def __init__(self, brand, model):
        self.brand = brand
        self.model = model

    def start_engine(self):
        print(f"The {self.brand} {self.model} engine is starting.")


# Creating an object (instance) of the Car class
my_car = Car("Toyota", "Camry")

# Accessing object attributes
print(my_car.brand)  # Output: Toyota
print(my_car.model)  # Output: Camry

# Calling object methods
my_car.start_engine()  # Output: The Toyota Camry engine is starting.

```

_encapsulation_

```py
class BankAccount:
    def __init__(self, account_number, balance):
        self.account_number = account_number
        self.__balance = balance  # Encapsulated private attribute

    def deposit(self, amount):
        self.__balance += amount

    def withdraw(self, amount):
        if amount <= self.__balance:
            self.__balance -= amount
        else:
            print("Insufficient balance.")

    def get_balance(self):
        return self.__balance


# Creating an object of the BankAccount class
account = BankAccount("123456789", 1000)

# Accessing public methods
account.deposit(500)
account.withdraw(200)
print(account.get_balance())  # Output: 1300

# Accessing private attribute (not recommended)
print(account._BankAccount__balance)  # Output: 1300 (Name Mangling)

```


_inheritance_

```py
class Animal:
    def __init__(self, name):
        self.name = name

    def speak(self):
        raise NotImplementedError("Subclass must implement this method.")


class Dog(Animal):
    def speak(self):
        return "Woof!"


class Cat(Animal):
    def speak(self):
        return "Meow!"


# Creating objects of derived classes
dog = Dog("Buddy")
cat = Cat("Whiskers")

# Calling the speak() method of the derived classes
print(dog.speak())  # Output: Woof!
print(cat.speak())  # Output: Meow!

```

_Polymorphism (Method Overriding)_

```py
class Shape:
    def area(self):
        raise NotImplementedError("Subclass must implement this method.")


class Rectangle(Shape):
    def __init__(self, width, height):
        self.width = width
        self.height = height

    def area(self):
        return self.width * self.height


class Circle(Shape):
    def __init__(self, radius):
        self.radius = radius

    def area(self):
        return 3.14 * self.radius * self.radius


# Creating objects of derived classes
rectangle = Rectangle(5, 3)
circle = Circle(7)

# Calling the area() method of the derived classes
print(rectangle.area())  # Output: 15
print(circle.area())  # Output: 153.86

```

_Polymorphism (Method Overloading)_

```py
class MathOperations:
    def add(self, a, b):
        return a + b

    def add(self, a, b, c):
        return a + b + c


# Creating an object of the MathOperations class
math = MathOperations()

# Calling the overloaded add() methods
print(math.add(2, 3))  # Output: 5
print(math.add(2, 3, 4))  # Output: 9

```


_Abstraction_


```py
from abc import ABC, abstractmethod

class Vehicle(ABC):
    @abstractmethod
    def start(self):
        pass

    @abstractmethod
    def stop(self):
        pass


class Car(Vehicle):
    def start(self):
        print("Car started.")

    def stop(self):
        print("Car stopped.")


# Creating an object of the Car class (Derived class)
car = Car()

# Calling the start() and stop() methods
car.start()  # Output: Car started.
car.stop()  # Output: Car stopped.

```
