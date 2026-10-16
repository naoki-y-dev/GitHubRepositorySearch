import XCTest
@testable import GitHubRepositorySearch

final class FavoritesServiceTests: XCTestCase {
    private var sut: FavoritesService!
    private var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: #file)
        testDefaults.removePersistentDomain(forName: #file)
        sut = FavoritesService(defaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: #file)
        sut = nil
        testDefaults = nil
        super.tearDown()
    }

    func test_load_returnsEmpty_whenNothingSaved() {
        XCTAssertTrue(sut.load().isEmpty)
    }

    func test_save_andLoad_roundtrip() {
        let repos = [Repository.mock(id: 1), Repository.mock(id: 2)]
        sut.save(repos)
        let loaded = sut.load()
        XCTAssertEqual(loaded.map(\.id), [1, 2])
    }

    func test_save_overwritesPreviousData() {
        sut.save([Repository.mock(id: 1)])
        sut.save([Repository.mock(id: 2), Repository.mock(id: 3)])
        let loaded = sut.load()
        XCTAssertEqual(loaded.map(\.id), [2, 3])
    }

    func test_save_emptyArray_clearsData() {
        sut.save([Repository.mock(id: 1)])
        sut.save([])
        XCTAssertTrue(sut.load().isEmpty)
    }
}
