import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  
  // История на съобщенията за чат интерфейса
  final List<Map<String, dynamic>> _messages = [];

  Future<void> _handleAnalyze() async {
    final input = _textController.text.trim();
    if (input.isEmpty) return;

    // Добавяме потребителското съобщение
    setState(() {
      _messages.add({'sender': 'user', 'text': input});
      _isLoading = true;
    });
    _textController.clear();

    try {
      final res = await ApiService.analyzeText(input);
      setState(() {
        _messages.add({'sender': 'ai', 'result': res});
      });
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'error', 'text': 'Грешка: $e'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFEA), // Пастелен бежов фон от скицата
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Увеличени отстъпи за по-голяма височина
              color: const Color(0xFFAFA093), // Кафяво-сива горна лента
              child: Row(
                children: [
                  // По-голямо лого Слово AI
                  Image.asset(
                    'assets/nobg.png',
                    height: 80, // Увеличено от 45 на 70 за по-видим акцент
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('СловоAI', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const Spacer(),
                  const Text(
                    'Вашият AI помощник за български език',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  const Spacer(),
                  // Горно меню (Начало, Статии, За нас)
                  TextButton(onPressed: () {}, child: const Text('Начало', style: TextStyle(color: Colors.white, fontSize: 16))),
                  TextButton(onPressed: () {}, child: const Text('Статии', style: TextStyle(color: Colors.white, fontSize: 16))),
                  TextButton(onPressed: () {}, child: const Text('За нас', style: TextStyle(color: Colors.white, fontSize: 16))),
                  const SizedBox(width: 16),
                  
                  // --- ПРЕЛИВАЩ БЪЛГАРСКИ ФЛАГ ---
                  Container(
                    width: 48,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,        // Бяло
                          Color(0xFF00966E),  // Трикольорно зелено
                          Color(0xFFD62612),  // Трикольорно червено
                        ],
                        stops: [0.33, 0.66, 1.0],
                    ),
                   ),
                 ),
                ],
              ),
            ),
            // --- MAIN BODY (Sidebar + Chat Area) ---
            Expanded(
              child: Row(
                children: [
                  // --- SIDEBAR ---
                  Container(
                    width: 220,
                    color: const Color(0xFFC7BCAB),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        _buildSidebarItem('Статии', isHeader: true),
                        _buildSidebarItem('Правопис'),
                        _buildSidebarItem('Граматика'),
                        _buildSidebarItem('Пунктуация'),
                        const Divider(height: 32),
                        _buildSidebarItem('Упражнения', isHeader: true),
                      ],
                    ),
                  ),

                  // --- CHAT DISPLAY AREA ---
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              if (msg['sender'] == 'user') {
                                return _buildUserBubble(msg['text']);
                              } else if (msg['sender'] == 'ai') {
                                return _buildAiBubble(msg['result']);
                              } else {
                                return _buildErrorBubble(msg['text']);
                              }
                            },
                          ),
                        ),

                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),

                        // --- BOTTOM INPUT BAR ---
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  decoration: InputDecoration(
                                    hintText: 'Въведете текст за проверка...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  onSubmitted: (_) => _handleAnalyze(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: _isLoading ? null : _handleAnalyze,
                                icon: const Icon(Icons.arrow_upward),
                                iconSize: 24,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(String title, {bool isHeader = false}) {
    return ListTile(
      dense: true,
      title: Text(
        title,
        style: TextStyle(
          fontSize: isHeader ? 18 : 15,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
      onTap: () {},
    );
  }

  Widget _buildUserBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _buildAiBubble(AnalysisResult res) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Коригиран текст:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 4),
            Text(res.correctedText, style: const TextStyle(fontSize: 15)),
            if (res.explanations.isNotEmpty) ...[
              const Divider(height: 20),
              const Text('Обяснения & Правила:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...res.explanations.map((exp) => Text('• $exp', style: const TextStyle(fontSize: 14))),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}


