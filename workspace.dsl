workspace "EventHub" "CEN 4020 Part 3 architecture" {

    model {
        buyer = person "Buyer" "Browses events and purchases tickets."
        admin = person "Administrator" "Manages exchange rates and reviews audit logs."

        eventhub = softwareSystem "EventHub" "Web-based event ticketing platform." {
            webapp = container "Flask Web Application" "Handles browser requests and business logic." "Python / Flask" {
                identity = component "Identity" "Registration, authentication, and access control."
                catalog = component "Catalog" "Event browsing, search, and event details."
                purchase = component "Purchase" "Checkout, orders, and ticket inventory transactions."
                pricing = component "Pricing" "Discounts, currency conversion, and rounding."
                audit = component "Audit" "Records purchase attempts and outcomes."
                administration = component "Administration" "Exchange-rate management and audit-log access."
            }

            database = container "Database" "Stores users, events, inventory, orders, exchange rates, and audit records." "Relational database" "Database"
        }

        buyer -> webapp "Browses events and purchases tickets" "HTTPS"
        admin -> webapp "Updates exchange rates and views audit logs" "HTTPS"

        identity -> database "Reads and writes accounts"
        catalog -> database "Reads events and inventory"
        purchase -> identity "Checks buyer authentication"
        purchase -> catalog "Validates event and availability"
        purchase -> pricing "Calculates final price"
        purchase -> database "Atomically updates inventory and orders"
        purchase -> audit "Records purchase outcome"
        pricing -> database "Reads exchange rates"
        audit -> database "Stores audit records"
        administration -> identity "Checks administrator privileges"
        administration -> database "Updates exchange rates and reads audit logs"
    }

    views {
        systemContext eventhub "EventHubContext" {
            include *
            autolayout lr
        }

        container eventhub "EventHubContainers" {
            include *
            autolayout lr
        }

        component webapp "EventHubComponents" {
            include *
            autolayout lr
        }

        styles {
            element "Person" {
                background #08427b
                color #ffffff
                shape person
            }

            element "Software System" {
                background #1168bd
                color #ffffff
            }

            element "Container" {
                background #438dd5
                color #ffffff
            }

            element "Component" {
                background #85bbf0
                color #000000
            }

            element "Database" {
                shape cylinder
            }
        }
    }
}