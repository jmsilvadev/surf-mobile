import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/helpers/currency_formatter.dart';
import 'package:surf_mobile/models/class_pack_model.dart';
import 'package:surf_mobile/providers/class_pack_provider.dart';
// Importe onde sua ClassCalendar está localizada:
import 'package:surf_mobile/screens/calendar_screen.dart';

class PackDetailScreen extends StatefulWidget {
  // Mudamos para StatefulWidget para gerenciar o estado do botão
  final ClassPack pack;

  const PackDetailScreen({super.key, required this.pack});

  @override
  State<PackDetailScreen> createState() => _PackDetailScreenState();
}

class _PackDetailScreenState extends State<PackDetailScreen> {
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    // Usamos context.read pois chamaremos uma função, não precisamos "escutar" mudanças de estado aqui
    final provider = context.read<ClassPackProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.pack.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Substitua o Image.network original por este:
          widget.pack.heroImageUrl != null &&
                  widget.pack.heroImageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.pack.heroImageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // Exibe algo enquanto a imagem carrega
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    // Caso a URL seja inválida ou falhe a conexão
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image,
                            size: 50, color: Colors.grey),
                      );
                    },
                  ),
                )
              : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported,
                      size: 50, color: Colors.grey),
                ),
          const SizedBox(height: 16),
          Text(widget.pack.description ?? ''),
          const SizedBox(height: 16),
          if (widget.pack.benefits.isNotEmpty)
            ...widget.pack.benefits.map(
              (b) => ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: Text(b),
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isPurchasing
                  ? null
                  : () async {
                      setState(() => _isPurchasing = true);

                      try {
                        await provider.buyPack(widget.pack);

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pack purchased successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // NAVEGAÇÃO PARA O CALENDÁRIO
                        // Usamos pushReplacement para que, se ele apertar "voltar", não volte para a tela de compra
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CalendarScreen()),
                        );
                      } catch (e) {
                        setState(() => _isPurchasing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error purchasing: $e')),
                        );
                      }
                    },
              child: _isPurchasing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Buy for ${CurrencyFormatter.euro(widget.pack.price)}'),
            ),
          ),
        ],
      ),
    );
  }
}
