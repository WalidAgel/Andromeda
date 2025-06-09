import 'package:flutter/material.dart';
import 'package:haloo/models/soal_model.dart';

class DetailSoalPage extends StatefulWidget {
  final SoalModel soal;

  const DetailSoalPage({
    super.key,
    required this.soal,
  });

  @override
  State<DetailSoalPage> createState() => _DetailSoalPageState();
}

class _DetailSoalPageState extends State<DetailSoalPage> {
  // Sample questions data - replace with actual data from your backend
  final List<QuestionItem> questions = [
    QuestionItem(
      id: "1",
      title: "Berpikir komputasi memiliki empat fondasi sebagai berikut, kecuali...",
      options: [
        "Opsi A: Abstraksi",
        "Opsi B: Pola",
        "Opsi C: Krisis",
        "Opsi D: Dekomposisi",
      ],
      correctAnswer: 2, // Index of correct answer (Krisis)
      createdAt: "2025-05-25",
    ),
    QuestionItem(
      id: "2",
      title: "Manakah yang bukan merupakan karakteristik algoritma yang baik?",
      options: [
        "Opsi A: Efisien",
        "Opsi B: Mudah dipahami",
        "Opsi C: Kompleks",
        "Opsi D: Dapat diimplementasi",
      ],
      correctAnswer: 2,
      createdAt: "2025-05-25",
    ),
    QuestionItem(
      id: "3",
      title: "Proses memecah masalah kompleks menjadi bagian-bagian kecil disebut?",
      options: [
        "Opsi A: Abstraksi",
        "Opsi B: Dekomposisi",
        "Opsi C: Pattern Recognition",
        "Opsi D: Algorithm Design",
      ],
      correctAnswer: 1,
      createdAt: "2025-05-25",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildQuestionsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Detail Soal',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.soal.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.soal.icon,
                  color: widget.soal.iconColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.soal.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tanggal Deadline: ${widget.soal.date}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Created at: ${widget.soal.date}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quiz Information Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildInfoItem(
                      Icons.quiz_outlined,
                      '${questions.length} Soal',
                    ),
                    const SizedBox(width: 20),
                    _buildInfoItem(
                      Icons.timer_outlined,
                      widget.soal.questionData?['durasi'] ?? 'N/A',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoItem(
                      Icons.grade_outlined,
                      'Min ${widget.soal.questionData?['passingScore'] ?? 0}%',
                    ),
                    const SizedBox(width: 20),
                    _buildInfoItem(
                      Icons.category_outlined,
                      widget.soal.category,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Soal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.soal.backgroundColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${questions.length} Soal',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.soal.backgroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final question = questions[index];
              return _buildQuestionCard(question, index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionItem question, int questionNumber) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.soal.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$questionNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isCorrect = index == question.correctAnswer;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          color: isCorrect ? Colors.green[700] : Colors.grey[700],
                          fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 16,
                      ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created At: ${question.createdAt}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Soal #$questionNumber',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.soal.backgroundColor,
                      fontWeight: FontWeight.w500,
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
}

// Question model for the detail page
class QuestionItem {
  final String id;
  final String title;
  final List<String> options;
  final int correctAnswer;
  final String createdAt;

  QuestionItem({
    required this.id,
    required this.title,
    required this.options,
    required this.correctAnswer,
    required this.createdAt,
  });
}