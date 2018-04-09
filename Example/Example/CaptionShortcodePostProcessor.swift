import Aztec
import Foundation


// MARK: - CaptionShortcodePostProcessor: Converts <figure><img><figcaption> structures into a [caption] shortcode.
//
class CaptionShortcodePostProcessor: HTMLProcessor {

    init() {
        super.init(tag: StandardElementType.figure.rawValue) { shortcode in
            guard let payload = shortcode.content else {
                return nil
            }

            /// Parse the Shortcode's Payload: We expect an [IMG, Figcaption]
            ///
            let rootNode = HTMLParser().parse(payload)
            
            guard let coreNode = rootNode.firstChild(ofType: .img) ?? rootNode.firstChild(ofType: .a),
                let figcaption = rootNode.firstChild(ofType: .figcaption)
            else {
                return nil
            }

            /// Serialize the Caption's Shortcode!
            ///
            let serializer = DefaultHTMLSerializer()
            var attributes = shortcode.attributes.named
            var imgId = ""
            var imgNode: ElementNode?

            // Find img child node of caption
            if coreNode.isNodeType(.img) {
                imgNode = coreNode
            } else {
                imgNode = coreNode.firstChild(ofType: .img)
            }

            if let imgNode = imgNode {
                let imgAttributes = imgNode.attributes
                for attribute in imgAttributes {
                    guard attribute.name != "src",
                        let attributeValue = attribute.value.toString() else {
                        continue
                    }

                    if attribute.name == "class" {
                        let classAttributes = attributeValue.components(separatedBy: " ")
                        for classAttribute in classAttributes {
                            if classAttribute.hasPrefix("wp-image-") {
                                imgId = classAttribute.replacingOccurrences(of: "wp-image-", with: "attachment_")
                            } else if classAttribute.hasPrefix("align"){
                                attributes["align"] = classAttribute
                            }
                        }
                    } else {
                        attributes[attribute.name] = attributeValue
                    }
                }
            }

            var attributesHTMLRepresentation: String = ""

            for (key, value) in attributes {
                attributesHTMLRepresentation += " \(key)=\"\(value)\""
            }

            var html = "[caption id=\"\(imgId)\"" + attributesHTMLRepresentation + "]"

            html += serializer.serialize(coreNode)

            for child in figcaption.children {
                html += serializer.serialize(child)
            }

            html += "[/caption]"
            
            return html
        }
    }
}
