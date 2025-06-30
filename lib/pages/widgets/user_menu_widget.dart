import 'package:flutter/material.dart';

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 22.0,
                ),
                SizedBox(height: 16.0),
                Text(
                  "Hello, John Doe",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: const Icon(Icons.home, size: 20.0, color: Colors.white),
              title: const Text(
                "Home",
                style: TextStyle(color: Colors.white),
              ),
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              childrenPadding: const EdgeInsets.only(left: 32.0),
              children: [
                ListTile(
                  onTap: () {
                    // Navigate to Dashboard
                  },
                  leading: const Icon(Icons.dashboard,
                      size: 18.0, color: Colors.white),
                  title: const Text("Dashboard"),
                  textColor: Colors.white,
                  dense: true,
                ),
                ListTile(
                  onTap: () {
                    // Navigate to Reports
                  },
                  leading: const Icon(Icons.analytics,
                      size: 18.0, color: Colors.white),
                  title: const Text("Reports"),
                  textColor: Colors.white,
                  dense: true,
                ),
                ListTile(
                  onTap: () {
                    // Navigate to Notifications
                  },
                  leading: const Icon(Icons.notifications,
                      size: 18.0, color: Colors.white),
                  title: const Text("Notifications"),
                  textColor: Colors.white,
                  dense: true,
                ),
              ],
            ),
          ),
          // Manage Items with Sub-options
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading:
                  const Icon(Icons.inventory, size: 20.0, color: Colors.white),
              title: const Text(
                "Manage Items",
                style: TextStyle(color: Colors.white),
              ),
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              childrenPadding: const EdgeInsets.only(left: 32.0),
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/showAllPosItemsPage');
                  },
                  leading:
                      const Icon(Icons.list, size: 18.0, color: Colors.white),
                  title: const Text("View Items"),
                  textColor: Colors.white,
                  dense: true,
                ),
                ListTile(
                  onTap: () {
                    // Navigate to Add Item
                    Navigator.pushNamed(context, '/AddPosItemForm');
                  },
                  leading:
                      const Icon(Icons.add, size: 18.0, color: Colors.white),
                  title: const Text("Add Item"),
                  textColor: Colors.white,
                  dense: true,
                ),
                ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/updateAllPosItemsPage');
                  },
                  leading:
                      const Icon(Icons.edit, size: 18.0, color: Colors.white),
                  title: const Text("Update Item"),
                  textColor: Colors.white,
                  dense: true,
                ),
                ListTile(
                  onTap: () {
                    // Navigate to Delete Item
                  },
                  leading:
                      const Icon(Icons.delete, size: 18.0, color: Colors.white),
                  title: const Text("Delete Item"),
                  textColor: Colors.white,
                  dense: true,
                ),
              ],
            ),
          ),
          // Home Section

          // Other Menu Items
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, '/myapp2');
            },
            leading: const Icon(Icons.monetization_on,
                size: 20.0, color: Colors.white),
            title: const Text("Second enxample"),
            textColor: Colors.white,
            dense: true,
          ),
          // ListTile(
          //   onTap: () {},
          //   leading: const Icon(Icons.shopping_cart,
          //       size: 20.0, color: Colors.white),
          //   title: const Text("Cart"),
          //   textColor: Colors.white,
          //   dense: true,
          // ),
          // ListTile(
          //   onTap: () {},
          //   leading:
          //       const Icon(Icons.star_border, size: 20.0, color: Colors.white),
          //   title: const Text("Favorites"),
          //   textColor: Colors.white,
          //   dense: true,
          // ),
          // ListTile(
          //   onTap: () {},
          //   leading:
          //       const Icon(Icons.settings, size: 20.0, color: Colors.white),
          //   title: const Text("Settings"),
          //   textColor: Colors.white,
          //   dense: true,
          // ),
        ],
      ),
    );
  }
}
