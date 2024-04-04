import UIKit

class CustomCollectionViewCell: UICollectionViewCell {

    static let identifier = "CustomCollectionViewCell"

    @IBOutlet var testTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
