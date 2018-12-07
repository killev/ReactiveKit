//
//  The MIT License (MIT)
//
//  Copyright (c) 2018 Srdan Rasic (@srdanrasic)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


public class Value<T> {
  var value: T? {
    return nil
  }
}

class WeakValue<T: AnyObject>: Value<T> {
  weak var val: T?
  init(_ value: T) {
    self.val = value
  }
  override var value: T? {
    return val
  }
}

class StrongValue<T>: Value<T> {
  let val: T
  init(_ value: T) {
    self.val = value
  }
  override var value: T? {
    return val
  }
}

class PropValue<U: PropertyProtocol>: Value<U.ProperyElement> {
  let val: U
  init(_ value: U) {
    self.val = value
  }
  override var value: U.ProperyElement? {
    return val.value
  }
}

class LatestValue<T>: Value<T> {
  var val: T?
  let bag = DisposeBag()
  init<U: SignalProtocol>(_ signal: U) where U.Element == T {
    super.init()
    signal.observeNext { [weak self] value in
      self?.val = value
      }.dispose(in: bag)
  }
  override var value: T? {
    return val
  }
}

public extension Value where T: AnyObject {
  static func weak(_ value: T)->Value<T> {
    return WeakValue<T>(value)
  }
}

public extension Value {
  static func strong(_ value: T)->Value<T> {
    return StrongValue<T>(value)
  }

  static func latest<U: SignalProtocol>(_ signal: U)->Value<T> where U.Element == T {
    return LatestValue<T>(signal)
  }

  static func val<U: PropertyProtocol>(_ prop: U)->Value<U.ProperyElement> {
    return PropValue(prop)
  }
}

public extension SignalProtocol {
  public func with1<U>(_ value: Value<U>) -> Signal<(Element, U), Error> {
    return Signal { observer in
      return self.observe { event in
        switch event {

        case .next(let element):
          if let val = value.value {
            observer.next ( (element, val) )
          }
        case .failed(let error):
          observer.failed(error)
        case .completed:
          observer.completed()
        }
      }
    }
  }

  public func with1<U1, U2>(_ value1: Value<U1>, _ value2: Value<U2>) -> Signal<(Element, U1, U2), Error> {
    return Signal { observer in
      return self.observe { event in
        switch event {

        case .next(let element):
          if let val1 = value1.value, let val2 = value2.value {
            observer.next ( (element, val1, val2) )
          }
        case .failed(let error):
          observer.failed(error)
        case .completed:
          observer.completed()
        }
      }
    }
  }
}
