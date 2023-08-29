import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

var profile = "https://avatars.githubusercontent.com/u/77667007?s=400&u=71647115fca0ec226f4b49de4a8120b1f356c21a&v=4";

List categories = [
  {"name": "All", "icon": FontAwesomeIcons.boxesStacked},
  {"name": "Apartment", "icon": Icons.location_city_rounded},
  {"name": "Condo", "icon": FontAwesomeIcons.solidBuilding},
  {"name": "Family Home", "icon": FontAwesomeIcons.house},
  {"name": "Office", "icon": Icons.desk},
  {"name": "Mansion", "icon": Icons.location_city_rounded},
  {"name": "Shop", "icon": FontAwesomeIcons.shop},
  {"name": "Studio", "icon": Icons.domain_rounded},
  {"name": "Villa", "icon": FontAwesomeIcons.buildingColumns},
];

List companies = [
  {
    "image":
        "https://images.unsplash.com/photo-1549517045-bc93de075e53?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NHx8Zm9vZHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
    "name": "TS Home",
    "location": "Phnom Penh, Cambodia",
    "type": "Broker",
    "is_favorite": false,
    "icon": Icons.domain_rounded
  },
  {
    "image":
        "https://images.unsplash.com/photo-1618221469555-7f3ad97540d6?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NHx8Zm9vZHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
    "name": "Century 21",
    "location": "Phnom Penh, Cambodia",
    "type": "Broker",
    "is_favorite": true,
    "icon": Icons.house_siding_rounded
  },
  {
    "image":
        "https://images.unsplash.com/photo-1625602812206-5ec545ca1231?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NHx8Zm9vZHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
    "name": "Dabest Pro",
    "location": "Phnom Penh, Cambodia",
    "type": "Broker",
    "is_favorite": true,
    "icon": Icons.home_work_rounded
  },
  {
    "image":
        "https://images.unsplash.com/photo-1625602812206-5ec545ca1231?ixid=MXwxMjA3fDB8MHxzZWFyY2h8NHx8Zm9vZHxlbnwwfHwwfA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
    "name": "Cam Reality",
    "location": "Phnom Penh, Cambodia",
    "type": "Broker",
    "is_favorite": true,
    "icon": Icons.location_city_rounded
  },
];
