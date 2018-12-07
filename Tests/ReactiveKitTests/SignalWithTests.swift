//
//  SignalWithTests.swift
//  ReactiveKit-iOS
//
//  Created by Peter Ovchinnikov on 12/7/18.
//  Copyright © 2018 DeclarativeHub. All rights reserved.
//

import XCTest
@testable import ReactiveKit

class SimpleClass {

}

class SignalWithTests: XCTestCase {

  func testValue() {
    XCTAssertNil(Value<String>().value, "It should always be nil")
  }

  func testWeakValue() {

    var weak: Value<SimpleClass>?
    let f = {
      let value = SimpleClass()
      weak = Value.weak(value)
      XCTAssertNotNil(weak!.value, "It should keep value inside the scope")
    }
    f()
    XCTAssertNil(weak!.value, "It should release value outside the scope")
  }

  func testStrongValue() {

    var strong: Value<SimpleClass>?
    let f = {
      let value = SimpleClass()
      strong = Value.strong(value)
      XCTAssertNotNil(strong!.value, "It should keep value inside the scope")
    }
    f()
    XCTAssertNotNil(strong!.value, "It should keep value even outside the scope")
  }

  func testPropertyValue() {

    var property: Value<String>?
    let f = {
      let value = Property("Old Value")
      property = Value<String>.val(value)
      XCTAssertEqual("Old Value", property!.value, "Ok. Getting current value")
      value.next("New Value")
    }
    f()
     XCTAssertEqual("New Value", property!.value, "New value is avaliable event out of scope")
  }

  func testLatestValue() {

    var latest: Value<String>?
    let f = {
      let signal = PublishSubject1<String>()
      latest = Value<String>.latest(signal)
      XCTAssertNil(latest!.value, "There's no value yet")
      signal.next("Old Value")
      XCTAssertEqual("Old Value", latest!.value, "Ok. Getting current value")
      signal.next("New Value")
    }
    f()
    XCTAssertEqual("New Value", latest!.value, "New value is avaliable event out of scope")
  }

  func testWith1Argument() {

    Signal<Int, TestError>.failed(.Error)
      .with1(.weak(SimpleClass()))
      .expect(events: [.failed(.Error)])

    Signal<Int, TestError>.just(1)
      .with1(.weak(SimpleClass()))
      .expectComplete(after: [])
    
    Signal<Int, TestError>.just(1)
      .with1(.strong(2))
      .expectComplete(after: [ (1, 2) ])

  }

  func testWith2Argument() {

    Signal<Int, TestError>.failed(.Error)
      .with1(.weak(SimpleClass()), .strong(0))
      .expect(events: [.failed(.Error)])

    Signal<Int, TestError>.just(1)
      .with1(.weak(SimpleClass()), .strong(0))
      .expectComplete(after: [])

    Signal<Int, TestError>.just(1)
      .with1(.strong(2), .strong(3))
      .expectComplete(after: [ (1, 2, 3) ])

  }

}
