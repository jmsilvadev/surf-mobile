import 'package:flutter/material.dart';
import 'package:surf_mobile/helpers/currency_formatter.dart';
import 'package:surf_mobile/models/class_pack_model.dart';

class PackCard extends StatelessWidget {
  final ClassPack pack;
  final VoidCallback onTap;

  const PackCard({super.key, required this.pack, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final priceText = pack.price != null
        ? CurrencyFormatter.euro(pack.price!)
        : 'Preço indisponível';

    print(pack.heroImageUrl);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                pack.heroImageUrl!,
                height: 160,
                cacheHeight: 320,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pack.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    priceText.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // SizedBox faz o botão ocupar toda a largura
                  SizedBox(
                    width: double.infinity,
                    height: 50, // Altura do botão
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        //  backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onTap,
                      child: const Text(
                        'View details',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ), // Fechado corretamente aqui
                    ), // Fechado corretamente aqui
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
