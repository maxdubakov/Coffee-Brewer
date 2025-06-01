import Foundation
import CoreData

struct CountryDataManager {
    static let shared = CountryDataManager()
    
    private let countriesData = [
        ("🇦🇫", "Afghanistan"), ("🇦🇱", "Albania"), ("🇩🇿", "Algeria"), ("🇦🇩", "Andorra"), ("🇦🇴", "Angola"), 
        ("🇦🇷", "Argentina"), ("🇦🇲", "Armenia"), ("🇦🇺", "Australia"), ("🇦🇹", "Austria"), ("🇦🇿", "Azerbaijan"),
        ("🇧🇸", "Bahamas"), ("🇧🇭", "Bahrain"), ("🇧🇩", "Bangladesh"), ("🇧🇧", "Barbados"), ("🇧🇾", "Belarus"), 
        ("🇧🇪", "Belgium"), ("🇧🇿", "Belize"), ("🇧🇯", "Benin"), ("🇧🇹", "Bhutan"), ("🇧🇴", "Bolivia"),
        ("🇧🇦", "Bosnia and Herzegovina"), ("🇧🇼", "Botswana"), ("🇧🇷", "Brazil"), ("🇧🇳", "Brunei"), ("🇧🇬", "Bulgaria"), 
        ("🇧🇫", "Burkina Faso"), ("🇧🇮", "Burundi"),
        ("🇰🇭", "Cambodia"), ("🇨🇲", "Cameroon"), ("🇨🇦", "Canada"), ("🇨🇻", "Cape Verde"), ("🇨🇫", "Central African Republic"), 
        ("🇹🇩", "Chad"), ("🇨🇱", "Chile"), ("🇨🇳", "China"), ("🇨🇴", "Colombia"), ("🇰🇲", "Comoros"),
        ("🇨🇬", "Congo"), ("🇨🇷", "Costa Rica"), ("🇭🇷", "Croatia"), ("🇨🇺", "Cuba"), ("🇨🇾", "Cyprus"), ("🇨🇿", "Czech Republic"),
        ("🇩🇰", "Denmark"), ("🇩🇯", "Djibouti"), ("🇩🇲", "Dominica"), ("🇩🇴", "Dominican Republic"),
        ("🇹🇱", "East Timor"), ("🇪🇨", "Ecuador"), ("🇪🇬", "Egypt"), ("🇸🇻", "El Salvador"), ("🇬🇶", "Equatorial Guinea"), 
        ("🇪🇷", "Eritrea"), ("🇪🇪", "Estonia"), ("🇪🇹", "Ethiopia"),
        ("🇫🇯", "Fiji"), ("🇫🇮", "Finland"), ("🇫🇷", "France"),
        ("🇬🇦", "Gabon"), ("🇬🇲", "Gambia"), ("🇬🇪", "Georgia"), ("🇩🇪", "Germany"), ("🇬🇭", "Ghana"), 
        ("🇬🇷", "Greece"), ("🇬🇩", "Grenada"), ("🇬🇹", "Guatemala"), ("🇬🇳", "Guinea"), ("🇬🇼", "Guinea-Bissau"), ("🇬🇾", "Guyana"),
        ("🇭🇹", "Haiti"), ("🇭🇳", "Honduras"), ("🇭🇺", "Hungary"),
        ("🇮🇸", "Iceland"), ("🇮🇳", "India"), ("🇮🇩", "Indonesia"), ("🇮🇷", "Iran"), ("🇮🇶", "Iraq"), 
        ("🇮🇪", "Ireland"), ("🇮🇱", "Israel"), ("🇮🇹", "Italy"), ("🇨🇮", "Ivory Coast"),
        ("🇯🇲", "Jamaica"), ("🇯🇵", "Japan"), ("🇯🇴", "Jordan"),
        ("🇰🇿", "Kazakhstan"), ("🇰🇪", "Kenya"), ("🇰🇮", "Kiribati"), ("🇰🇵", "North Korea"), ("🇰🇷", "South Korea"), 
        ("🇽🇰", "Kosovo"), ("🇰🇼", "Kuwait"), ("🇰🇬", "Kyrgyzstan"),
        ("🇱🇦", "Laos"), ("🇱🇻", "Latvia"), ("🇱🇧", "Lebanon"), ("🇱🇸", "Lesotho"), ("🇱🇷", "Liberia"), 
        ("🇱🇾", "Libya"), ("🇱🇮", "Liechtenstein"), ("🇱🇹", "Lithuania"), ("🇱🇺", "Luxembourg"),
        ("🇲🇬", "Madagascar"), ("🇲🇼", "Malawi"), ("🇲🇾", "Malaysia"), ("🇲🇻", "Maldives"), ("🇲🇱", "Mali"), 
        ("🇲🇹", "Malta"), ("🇲🇭", "Marshall Islands"), ("🇲🇷", "Mauritania"), ("🇲🇺", "Mauritius"), ("🇲🇽", "Mexico"),
        ("🇫🇲", "Micronesia"), ("🇲🇩", "Moldova"), ("🇲🇨", "Monaco"), ("🇲🇳", "Mongolia"), ("🇲🇪", "Montenegro"), 
        ("🇲🇦", "Morocco"), ("🇲🇿", "Mozambique"), ("🇲🇲", "Myanmar"),
        ("🇳🇦", "Namibia"), ("🇳🇷", "Nauru"), ("🇳🇵", "Nepal"), ("🇳🇱", "Netherlands"), ("🇳🇿", "New Zealand"), 
        ("🇳🇮", "Nicaragua"), ("🇳🇪", "Niger"), ("🇳🇬", "Nigeria"), ("🇲🇰", "North Macedonia"), ("🇳🇴", "Norway"),
        ("🇴🇲", "Oman"),
        ("🇵🇰", "Pakistan"), ("🇵🇼", "Palau"), ("🇵🇸", "Palestine"), ("🇵🇦", "Panama"), ("🇵🇬", "Papua New Guinea"), 
        ("🇵🇾", "Paraguay"), ("🇵🇪", "Peru"), ("🇵🇭", "Philippines"), ("🇵🇱", "Poland"), ("🇵🇹", "Portugal"),
        ("🇶🇦", "Qatar"),
        ("🇷🇴", "Romania"), ("🇷🇺", "Russia"), ("🇷🇼", "Rwanda"),
        ("🇰🇳", "Saint Kitts and Nevis"), ("🇱🇨", "Saint Lucia"), ("🇻🇨", "Saint Vincent and the Grenadines"), 
        ("🇼🇸", "Samoa"), ("🇸🇲", "San Marino"), ("🇸🇹", "Sao Tome and Principe"),
        ("🇸🇦", "Saudi Arabia"), ("🇸🇳", "Senegal"), ("🇷🇸", "Serbia"), ("🇸🇨", "Seychelles"), ("🇸🇱", "Sierra Leone"), 
        ("🇸🇬", "Singapore"), ("🇸🇰", "Slovakia"), ("🇸🇮", "Slovenia"), ("🇸🇧", "Solomon Islands"),
        ("🇸🇴", "Somalia"), ("🇿🇦", "South Africa"), ("🇸🇸", "South Sudan"), ("🇪🇸", "Spain"), ("🇱🇰", "Sri Lanka"), 
        ("🇸🇩", "Sudan"), ("🇸🇷", "Suriname"), ("🇸🇪", "Sweden"), ("🇨🇭", "Switzerland"), ("🇸🇾", "Syria"),
        ("🇹🇼", "Taiwan"), ("🇹🇯", "Tajikistan"), ("🇹🇿", "Tanzania"), ("🇹🇭", "Thailand"), ("🇹🇬", "Togo"), 
        ("🇹🇴", "Tonga"), ("🇹🇹", "Trinidad and Tobago"), ("🇹🇳", "Tunisia"), ("🇹🇷", "Turkey"),
        ("🇹🇲", "Turkmenistan"), ("🇹🇻", "Tuvalu"),
        ("🇺🇬", "Uganda"), ("🇺🇦", "Ukraine"), ("🇦🇪", "United Arab Emirates"), ("🇬🇧", "United Kingdom"), 
        ("🇺🇸", "United States"), ("🇺🇾", "Uruguay"), ("🇺🇿", "Uzbekistan"),
        ("🇻🇺", "Vanuatu"), ("🇻🇦", "Vatican City"), ("🇻🇪", "Venezuela"), ("🇻🇳", "Vietnam"),
        ("🇾🇪", "Yemen"),
        ("🇿🇲", "Zambia"), ("🇿🇼", "Zimbabwe")
    ]
    
    /// Populates countries if needed using a background context
    func populateCountriesIfNeeded(in context: NSManagedObjectContext) {
        context.perform {
            // Check if countries already exist
            let fetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
            let count = (try? context.count(for: fetchRequest)) ?? 0
            
            guard count == 0 else { 
                return 
            }
            
            // Create country entities
            for (flag, name) in self.countriesData {
                let country = Country(context: context)
                country.id = UUID()
                country.flag = flag
                country.name = name
            }
            
            // Save the context
            do {
                try context.save()
                print("Successfully populated \(self.countriesData.count) countries")
            } catch {
                print("Failed to populate countries: \(error)")
            }
        }
    }
    
    /// Populates countries for preview/testing
    func populateCountriesForPreview(in context: NSManagedObjectContext) {
        // For preview, we directly populate without checking
        for (flag, name) in countriesData {
            let country = Country(context: context)
            country.id = UUID()
            country.flag = flag
            country.name = name
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to populate preview countries: \(error)")
        }
    }
}
