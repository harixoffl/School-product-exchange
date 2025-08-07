// lib/widgets/city_dropdown.dart
import 'package:flutter/material.dart';

class CityDropdown extends StatelessWidget {
  final String? selectedCity;
  final Function(String?)? onChanged;
  final bool showAllOption;

  const CityDropdown({super.key, required this.selectedCity, this.onChanged, this.showAllOption = false});

  @override
  Widget build(BuildContext context) {
    final cities = ['Ondipudur', 'Singanallur', 'Ukkadam', 'Hope college', 'Gandhipuram', 'R.S puram', 'Sulur'];

    return DropdownButtonFormField<String>(
      value: selectedCity,
      decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
      items: [
        if (showAllOption) const DropdownMenuItem(value: null, child: Text('All Cities')),
        ...cities.map((city) {
          return DropdownMenuItem(value: city, child: Text(city));
        }),
      ],
      onChanged: onChanged,
    );
  }
}
