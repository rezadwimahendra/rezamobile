import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/professional_bloc.dart';
import '../bloc/professional_event.dart';
import '../bloc/professional_state.dart';

class SetupProfessionalPage extends StatefulWidget {
  final String roleType; // 'trainer' atau 'gym'

  const SetupProfessionalPage({super.key, required this.roleType});

  @override
  State<SetupProfessionalPage> createState() => _SetupProfessionalPageState();
}

class _SetupProfessionalPageState extends State<SetupProfessionalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  
  File? _avatarFile;
  final List<File> _galleryFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isEditMode = false;
  String? _existingAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final userId = sl<AuthBloc>().state.user?.id;
    if (userId != null) {
      context.read<ProfessionalBloc>().add(ProfessionalDataRequested(userId: userId, role: widget.roleType));
    }
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Kompresi untuk kecepatan
    );
    if (image != null) {
      setState(() => _avatarFile = File(image.path));
    }
  }

  Future<void> _pickGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 50, // Kompresi untuk kecepatan
    );
    if (images.isNotEmpty) {
      setState(() {
        _galleryFiles.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;
    
    final userId = sl<AuthBloc>().state.user?.id;
    if (userId == null) return;

    final rawPriceStr = _priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final priceNumeric = int.tryParse(rawPriceStr) ?? 0;

    context.read<ProfessionalBloc>().add(ProfessionalRegistered(
      userId: userId,
      role: widget.roleType,
      name: _nameCtrl.text,
      description: _bioCtrl.text,
      price: priceNumeric,
      specialty: widget.roleType == 'trainer' ? _specialtyCtrl.text : null,
      location: widget.roleType == 'gym' ? _specialtyCtrl.text : null,
      avatarFile: _avatarFile,
      galleryFiles: _galleryFiles.isNotEmpty ? _galleryFiles : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isTrainer = widget.roleType == 'trainer';
    final primaryColor = Theme.of(context).primaryColor;

    return BlocListener<ProfessionalBloc, ProfessionalState>(
      listener: (context, state) {
        if (state.status == ProfessionalStatus.success) {
          if (state.professional != null) {
            // Ini saat memuat data yang sudah ada (Load Mode)
            setState(() {
              _isEditMode = true;
              _nameCtrl.text = state.professional!.name;
              _bioCtrl.text = state.professional!.description;
              _priceCtrl.text = state.professional!.price.toString();
              _specialtyCtrl.text = isTrainer ? (state.professional!.specialty ?? '') : (state.professional!.location ?? '');
              _existingAvatarUrl = state.professional!.avatar;
            });
          } else {
            // Ini saat berhasil Simpan/Terbitkan
            Navigator.of(context).pop(); // Back to Dashboard
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditMode ? 'Profil berhasil diperbarui!' : 'Profil bisnis berhasil diterbitkan!'), 
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (state.status == ProfessionalStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal: ${state.errorMessage ?? "Terjadi kesalahan"}'), 
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_isEditMode ? 'Edit Profil Bisnis' : 'Setup Profil Baru'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBar: _buildBottomAction(primaryColor),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildAvatarPicker(primaryColor),
                const SizedBox(height: 40),
                
                const Text('INFORMASI DASAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.5)),
                const SizedBox(height: 16),
                
                _buildField(
                  label: 'Nama Lengkap',
                  hint: '',
                  controller: _nameCtrl,
                ),
                const SizedBox(height: 20),
                
                _buildField(
                  label: isTrainer ? 'Keahlian' : 'Lokasi Lengkap',
                  hint: '',
                  controller: _specialtyCtrl,
                ),
                const SizedBox(height: 20),
                
                _buildField(
                  label: isTrainer ? 'Tarif per Sesi' : 'Iuran per Bulan',
                  hint: '',
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 32),
                
                const Text('BIO & DESKRIPSI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.5)),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Tentang Bisnis Anda',
                  hint: '',
                  controller: _bioCtrl,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                
                const Text('GALERI PORTOFOLIO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                const Text('Unggah foto-foto dokumentasi untuk ditampilkan di Jelajah.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                _buildGalleryPicker(primaryColor),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker(Color primaryColor) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    image: _avatarFile != null 
                        ? DecorationImage(image: FileImage(_avatarFile!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: (_avatarFile == null && _existingAvatarUrl == null)
                      ? const Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 30)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, size: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Foto Profil',
            style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryPicker(Color primaryColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _galleryFiles.length + 1,
      itemBuilder: (context, index) {
        if (index == _galleryFiles.length) {
          return GestureDetector(
            onTap: _pickGallery,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
            ),
          );
        }
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(image: FileImage(_galleryFiles[index]), fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 5, right: 5,
              child: GestureDetector(
                onTap: () => setState(() => _galleryFiles.removeAt(index)),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildField({required String label, required String hint, required TextEditingController controller, int maxLines = 1, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
          ),
          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildBottomAction(Color primaryColor) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocBuilder<ProfessionalBloc, ProfessionalState>(
          builder: (context, state) {
            final isLoading = state.status == ProfessionalStatus.loading;
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_isEditMode ? 'Simpan Perubahan' : 'Terbitkan Sekarang', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            );
          },
        ),
      ),
    );
  }
}
