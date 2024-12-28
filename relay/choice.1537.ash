import "relay/choice.ash";
import "relay/TakerSpaceRelay.ash";

//Choice	override

void main(string page_text_encoded)
{
	string page_text = page_text_encoded.choiceOverrideDecodePageText();
    string newPage = handleTakerSpace(page_text); 

    newPage.write();	
}
