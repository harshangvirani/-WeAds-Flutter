import 'package:flutter/material.dart';

class CategoryIconHelper {
  /// Returns a relevant Material Icon based on the given category name.
  /// Mapped specifically to the categories returned by the API.
  static IconData getIconForCategory(String categoryName) {
    switch (categoryName) {
      case "Agriculture":
        return Icons.agriculture;
      case "All Your City Ads":
        return Icons.location_city;
      case "Animal / Bird":
        return Icons.pets;
      case "Beauty Parlor / Salon":
        return Icons.face_retouching_natural;
      case "Car / Bike / Spare Parts":
        return Icons.directions_car;
      case "Chai & Pan Masala":
        return Icons.emoji_food_beverage;
      case "Clothes / Fashion":
        return Icons.checkroom;
      case "Coconuts / Fruits / Vegetables":
        return Icons.eco;
      case "Cold Drink / Ice Cream":
        return Icons.icecream;
      case "Doctor / Medical":
        return Icons.local_hospital;
      case "Electronics":
        return Icons.devices;
      case "Factory / Industry":
        return Icons.factory;
      case "Food / Restaurant / Fast Food":
        return Icons.restaurant;
      case "Furniture / Kitchen Ware":
        return Icons.chair;
      case "Grocery Store":
        return Icons.local_grocery_store;
      case "Job / Hirings":
        return Icons.work;
      case "Lawyer / Other Services Officer":
        return Icons.gavel;
      case "Mobile":
        return Icons.smartphone;
      case "Other / Buy Sell / Store Items":
        return Icons.storefront;
      case "Property / Rental Home":
        return Icons.real_estate_agent;
      case "School / Tuition Class / Training":
        return Icons.school;
      case "Services / Repairing / Garage":
        return Icons.build;
      case "Sweets / Namkeen / Bakery / Wafers":
        return Icons.bakery_dining;
      case "Taxi / Ride / Auto Rickshaw":
        return Icons.local_taxi;
      case "Transport / Commercial Vehicle":
        return Icons.local_shipping;
      default:
        return Icons.category;
    }
  }
}
