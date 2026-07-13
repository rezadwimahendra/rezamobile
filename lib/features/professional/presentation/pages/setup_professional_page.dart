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
import 'package:latlong2/latlong.dart';
import 'package:pocketbase/pocketbase.dart';
import '../widgets/map_picker_dialog.dart';

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
  final _nonMemberPriceCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _openDaysCtrl = TextEditingController();
  
  File? _avatarFile;
  final List<File> _galleryFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isEditMode = false;
  bool _isDataLoaded = false;
  String? _existingAvatarUrl;
  String? _existingProfessionalId;
  String? _openTime;
  String? _closeTime;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specialtyCtrl.dispose();
    _priceCtrl.dispose();
    _nonMemberPriceCtrl.dispose();
    _bioCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _openDaysCtrl.dispose();
    super.dispose();
  }

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

    int? nonMemberPriceNumeric;
    if (widget.roleType == 'gym') {
      final rawNonMemberPriceStr = _nonMemberPriceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      nonMemberPriceNumeric = int.tryParse(rawNonMemberPriceStr);
    }

    final double? lat = double.tryParse(_latCtrl.text);
    final double? lng = double.tryParse(_lngCtrl.text);

    context.read<ProfessionalBloc>().add(ProfessionalRegistered(
      userId: userId,
      role: widget.roleType,
      name: _nameCtrl.text,
      description: _bioCtrl.text,
      price: priceNumeric,
      nonMemberPrice: nonMemberPriceNumeric,
      specialty: widget.roleType == 'trainer' ? _specialtyCtrl.text : null,
      location: widget.roleType == 'gym' ? _specialtyCtrl.text : null,
      avatarFile: _avatarFile,
      galleryFiles: _galleryFiles.isNotEmpty ? _galleryFiles : null,
      latitude: lat,
      longitude: lng,
      openTime: widget.roleType == 'gym' ? _openTime : null,
      closeTime: widget.roleType == 'gym' ? _closeTime : null,
      openDays: widget.roleType == 'gym' ? _openDaysCtrl.text : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isTrainer = widget.roleType == 'trainer';
    final primaryColor = Theme.of(context).primaryColor;

    return BlocListener<ProfessionalBloc, ProfessionalState>(
      listener: (context, state) {
        if (state.status == ProfessionalStatus.success) {
          if (state.professional != null && !_isDataLoaded) {
            // Ini saat memuat data yang sudah ada (Load Mode)
            setState(() {
              _isEditMode = true;
              _isDataLoaded = true;
              _nameCtrl.text = state.professional!.name;
              _bioCtrl.text = state.professional!.description;
              _priceCtrl.text = state.professional!.price.toString();
              _nonMemberPriceCtrl.text = state.professional!.nonMemberPrice?.toString() ?? '';
              _specialtyCtrl.text = isTrainer ? (state.professional!.specialty ?? '') : (state.professional!.location ?? '');
              _existingAvatarUrl = state.professional!.avatar;
              _latCtrl.text = state.professional!.latitude?.toString() ?? '';
              _lngCtrl.text = state.professional!.longitude?.toString() ?? '';
              _openTime = state.professional!.openTime;
              _closeTime = state.professional!.closeTime;
              _openDaysCtrl.text = state.professional!.openDays ?? '';
              _existingProfessionalId = state.professional!.id;
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
                if (!isTrainer) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Koordinat Lokasi Peta',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _latCtrl.text.isNotEmpty && _lngCtrl.text.isNotEmpty
                                    ? 'Lat: ${_latCtrl.text}\nLng: ${_lngCtrl.text}'
                                    : 'Belum ditentukan (Ketuk tombol peta di bawah untuk menentukan)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _latCtrl.text.isNotEmpty ? Colors.black87 : Colors.grey.shade500,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: Color(0xFFFFB800), width: 1.5),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        final curLat = double.tryParse(_latCtrl.text) ?? -6.2000;
                        final curLng = double.tryParse(_lngCtrl.text) ?? 106.8166;
                        final LatLng? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPickerDialog(
                              initialLocation: LatLng(curLat, curLng),
                            ),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _latCtrl.text = result.latitude.toString();
                            _lngCtrl.text = result.longitude.toString();
                          });
                        }
                      },
                      icon: const Icon(Icons.map, color: Color(0xFFFFB800)),
                      label: const Text('Pilih Lokasi dari Peta', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                _buildField(
                  label: isTrainer ? 'Tarif per Sesi' : 'Harga Member (1 Bulan)',
                  hint: 'e.g. 350000',
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                if (!isTrainer) ...[
                  const SizedBox(height: 20),
                  _buildField(
                    label: 'Harga Non-Member (1 Hari)',
                    hint: 'e.g. 45000',
                    controller: _nonMemberPriceCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 24),
                  const Text('JADWAL OPERASIONAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Hari Kerja/Operasional',
                    hint: 'e.g. Senin - Sabtu atau Setiap Hari',
                    controller: _openDaysCtrl,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(color: Colors.grey.shade300),
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: _openTime != null
                                  ? TimeOfDay(
                                      hour: int.parse(_openTime!.split(':')[0]),
                                      minute: int.parse(_openTime!.split(':')[1]),
                                    )
                                  : const TimeOfDay(hour: 8, minute: 0),
                            );
                            if (picked != null) {
                              setState(() {
                                final hour = picked.hour.toString().padLeft(2, '0');
                                final minute = picked.minute.toString().padLeft(2, '0');
                                _openTime = '$hour:$minute';
                              });
                            }
                          },
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.access_time_filled, color: Colors.green),
                          ),
                          label: Text(
                            _openTime != null ? 'Buka: $_openTime' : 'Pilih Jam Buka',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(color: Colors.grey.shade300),
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: _closeTime != null
                                  ? TimeOfDay(
                                      hour: int.parse(_closeTime!.split(':')[0]),
                                      minute: int.parse(_closeTime!.split(':')[1]),
                                    )
                                  : const TimeOfDay(hour: 22, minute: 0),
                            );
                            if (picked != null) {
                              setState(() {
                                final hour = picked.hour.toString().padLeft(2, '0');
                                final minute = picked.minute.toString().padLeft(2, '0');
                                _closeTime = '$hour:$minute';
                              });
                            }
                          },
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.access_time_filled, color: Colors.red),
                          ),
                          label: Text(
                            _closeTime != null ? 'Tutup: $_closeTime' : 'Pilih Jam Tutup',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
                        : (_existingAvatarUrl != null && _existingAvatarUrl!.isNotEmpty && _existingProfessionalId != null)
                            ? DecorationImage(
                                image: NetworkImage(
                                  '${sl<PocketBase>().baseUrl}/api/files/${widget.roleType == "trainer" ? "trainers" : "gyms"}/$_existingProfessionalId/$_existingAvatarUrl?t=${DateTime.now().millisecondsSinceEpoch}',
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: (_avatarFile == null && (_existingAvatarUrl == null || _existingAvatarUrl!.isEmpty))
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

  Widget _buildField({required String label, required String hint, required TextEditingController controller, int maxLines = 1, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters, bool isRequired = true}) {
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
          validator: (v) {
            if (isRequired && (v == null || v.isEmpty)) {
              return 'Wajib diisi';
            }
            return null;
          },
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
