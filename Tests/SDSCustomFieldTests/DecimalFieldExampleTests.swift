//
//  DecimalFieldExampleTests.swift
//
//  Created by : Tomoaki Yagishita on 2022/03/21
//  © 2022  SmallDeskSoftware
//

import XCTest
@testable import SDSCustomField

class DecimalFieldExampleTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_ViewModel_acceptableString() async throws {
        let sut = DecimalFieldViewModel(Decimal(string:"1234")!)
        XCTAssertEqual(sut.canAccept("12345"), true)
        XCTAssertEqual(sut.canAccept("12345.678"), true)
        XCTAssertEqual(sut.canAccept("12,345"), true)
        
        XCTAssertEqual(sut.canAccept(NumberFormatter().currencySymbol + "12,345"), true)
    }
    
    func test_ViewModel_apply_cancel() async throws {
        let sut = DecimalFieldViewModel(Decimal(string:"1234")!)
        XCTAssertEqual(sut.canAccept("12345"), true)
        sut.updateFieldString("12345")
        XCTAssertNotEqual(sut.fieldString, sut.stringSharedWithUpperView)
        XCTAssertEqual(sut.apply(), true)
        XCTAssertEqual(sut.fieldString, sut.stringSharedWithUpperView)

        sut.updateFieldString("1234abc")
        XCTAssertNotEqual(sut.fieldString, sut.stringSharedWithUpperView)
        sut.cancel()
        XCTAssertEqual(sut.fieldString, sut.stringSharedWithUpperView)
    }
    
    
}
