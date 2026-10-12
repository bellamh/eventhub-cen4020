workspace "EventHub Ticketing - Original Architecture (Part 3)" "Container and component views derived from Parts 1-2, before Call 3" {

    model {
        buyer = person "Ticket Buyer" "Registers, signs in, browses and searches events, and buys tickets. USF students are buyers whose account email ends in usf.edu. Eligibility is a rule on the account, not a separate role."

        eventhub = softwareSystem "EventHub Ticketing System" "Public web platform for browsing events and purchasing tickets priced in USD, EUR, GBP, or JPY. Payments are simulated and confirmations are on-screen only." {

            webApp = container "Web Application" "Serves responsive web pages and handles all HTTP requests from buyers." "Python 3, Flask" {
                validation = component "Input Validation" "Validates all data entering the system at the request boundary (form fields, quantities, currency codes, search text) before any internal use." "Python"
                identity = component "Identity and Session" "Registration, login, password hashing, sessions with inactivity expiry, and account email lookup." "Python, Flask"
                catalog = component "Catalog" "Browses upcoming events, searches by artist or venue, serves event pages, and displays availability." "Python, Flask"
                purchase = component "Purchase" "Standard and quick-buy purchase flow, quantity and currency selection, 8-ticket per-account-per-event cap, on-screen confirmation, and order history." "Python, Flask"
                pricing = component "Pricing" "Computes the buyer price: USF student discount eligibility, discount applied before conversion, conversion from USD base price using static rates, rounding once at the end." "Python"
                inventory = component "Inventory" "Re-checks ticket availability and decrements the count as one atomic step. No ticket holds." "Python"
                audit = component "Audit Log" "Records timestamp, user, event, quantity, currency, and outcome of every purchase attempt." "Python"
            }

            db = container "Relational Database" "Stores accounts with hashed passwords, events, artists, venues, inventory counts, orders, and audit log entries." "Relational database (technology TBD)" "Database"

            configFiles = container "Configuration and Seed Data" "Static exchange rates from USD, supported currency list, USF discount settings, and event, artist, and venue data loaded at setup." "Versioned data files (format TBD)"
        }

        # Container-level relationships
        buyer -> webApp "Registers, signs in, browses, searches, and buys tickets" "HTTPS"
        webApp -> db "Reads and writes accounts, events, inventory, orders, and audit entries" "SQL"
        webApp -> configFiles "Loads exchange rates, currencies, and seed data at startup" "File read"

        # Component-level relationships
        buyer -> validation "Sends requests" "HTTPS"
        validation -> identity "Passes validated registration and login input"
        validation -> catalog "Passes validated browse and search input"
        validation -> purchase "Passes validated purchase and order-history input"
        purchase -> identity "Confirms the buyer is signed in before showing or recording any checkout data"
        purchase -> catalog "Looks up the selected event and its availability"
        purchase -> pricing "Requests the buyer price for the chosen quantity and currency"
        purchase -> inventory "Requests availability re-check and decrement"
        purchase -> audit "Records each purchase attempt"
        purchase -> db "Writes orders and reads order history"
        pricing -> identity "Reads account email domain for USF eligibility"
        pricing -> catalog "Reads the USF-hosted flag for the event"
        pricing -> configFiles "Reads exchange rates and supported currencies"
        catalog -> db "Reads events, artists, and venues"
        identity -> db "Stores accounts and sessions"
        inventory -> db "Checks and decrements ticket counts in one transaction"
        audit -> db "Writes audit entries in the same transaction as the inventory update"
    }

    views {
        systemContext eventhub "SystemContext" "Level 1: EventHub and its single human actor" {
            include *
            autoLayout lr
        }

        container eventhub "ContainerView" "Level 2: containers inside EventHub" {
            include *
            autoLayout lr
        }

        component webApp "ComponentView" "Level 3: components inside the Web Application" {
            include *
            autoLayout lr
        }

        styles {
            element "Database" {
                shape Cylinder
            }
        }
    }
}