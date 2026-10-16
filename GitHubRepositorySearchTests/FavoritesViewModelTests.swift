import XCTest
@testable import GitHubRepositorySearch

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    private var sut: FavoritesViewModel!
    private var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: #file)
        testDefaults.removePersistentDomain(forName: #file)
        sut = FavoritesViewModel(service: FavoritesService(defaults: testDefaults))
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: #file)
        sut = nil
        testDefaults = nil
        super.tearDown()
    }

    func test_isFavorite_returnsFalse_initially() {
        XCTAssertFalse(sut.isFavorite(.mock(id: 1)))
    }

    func test_toggle_addsFavorite() {
        sut.toggle(.mock(id: 1))
        XCTAssertTrue(sut.isFavorite(.mock(id: 1)))
        XCTAssertEqual(sut.favorites.count, 1)
    }

    func test_toggle_removesFavorite_whenAlreadyFavorited() {
        sut.toggle(.mock(id: 1))
        sut.toggle(.mock(id: 1))
        XCTAssertFalse(sut.isFavorite(.mock(id: 1)))
        XCTAssertTrue(sut.favorites.isEmpty)
    }

    func test_toggle_insertsAtFront() {
        sut.toggle(.mock(id: 1))
        sut.toggle(.mock(id: 2))
        XCTAssertEqual(sut.favorites.first?.id, 2)
    }

    func test_toggle_persistsAcrossInstances() {
        sut.toggle(.mock(id: 99))
        let newVM = FavoritesViewModel(service: FavoritesService(defaults: testDefaults))
        XCTAssertTrue(newVM.isFavorite(.mock(id: 99)))
    }

    func test_isFavorite_matchesById_notByReference() {
        sut.toggle(.mock(id: 1, name: "original"))
        XCTAssertTrue(sut.isFavorite(.mock(id: 1, name: "different-name")))
    }
}
