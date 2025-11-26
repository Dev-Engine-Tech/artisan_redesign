import 'package:dio/dio.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/data/base_remote_data_source.dart';
import '../models/invoice_model.dart';
import '../models/invoice_dashboard_model.dart';

abstract class InvoiceRemoteDataSource {
  Future<List<InvoiceModel>> getInvoices({
    int page = 1,
    String? status,
  });

  Future<InvoiceModel> getInvoiceById(String id);

  Future<InvoiceModel> createInvoice(Map<String, dynamic> data);

  Future<InvoiceModel> updateInvoice(String id, Map<String, dynamic> data);

  Future<void> deleteInvoice(String id);

  Future<void> sendInvoice(String id);

  Future<InvoiceModel> markInvoiceAsPaid(
    String id,
    Map<String, dynamic> paymentData,
  );

  Future<String> generateInvoicePdf(String id);

  Future<InvoiceDashboardModel> getDashboard();
}

class InvoiceRemoteDataSourceImpl extends BaseRemoteDataSource
    implements InvoiceRemoteDataSource {
  InvoiceRemoteDataSourceImpl(super.dio);

  String _asDate(dynamic v) {
    if (v == null) return '';
    final s = v.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  Map<String, dynamic> _buildPayload(Map<String, dynamic> src) {
    final payload = <String, dynamic>{};
    final customer =
        src['customer'] ?? src['customer_id'] ?? src['customer_uuid'];
    if (customer != null && customer.toString().isNotEmpty) {
      payload['customer'] = customer;
    }
    if (src['client_name'] != null) payload['client_name'] = src['client_name'];
    if (src['client_email'] != null)
      payload['client_email'] = src['client_email'];
    if (src['issue_date'] != null)
      payload['issue_date'] = _asDate(src['issue_date']);
    if (src['due_date'] != null) payload['due_date'] = _asDate(src['due_date']);
    if (src['notes'] != null) payload['notes'] = src['notes'];
    if (src['delivery_address'] != null)
      payload['delivery_address'] = src['delivery_address'];
    payload['currency'] = (src['currency'] ?? 'NGN').toString();

    // Invoice-level tax_rate allowed
    if (src['tax_rate'] != null) payload['tax_rate'] = src['tax_rate'];

    final rawItems = (src['items'] is List
            ? src['items']
            : (src['line_items'] is List ? src['line_items'] : null)) ??
        [];
    final items = <Map<String, dynamic>>[];
    for (final it in rawItems) {
      if (it is Map) {
        final m = Map<String, dynamic>.from(it);
        final desc =
            (m['description'] ?? m['item_description'] ?? '').toString();
        final qraw = (m['quantity'] ?? m['qty'] ?? 1);
        final qty =
            qraw is num ? qraw.round() : int.tryParse(qraw.toString()) ?? 1;
        final uraw = (m['unit_price'] ?? m['unitPrice'] ?? m['price'] ?? 0);
        final unit = uraw is num
            ? uraw.toDouble()
            : double.tryParse(uraw.toString()) ?? 0.0;
        final discountRaw = m['discount'];
        final itemTaxRaw = (m['tax_rate'] ?? m['taxRate']);
        final itemTax = itemTaxRaw is num
            ? itemTaxRaw.toDouble()
            : double.tryParse(itemTaxRaw?.toString() ?? '');
        final out = <String, dynamic>{
          'description': desc,
          'quantity': qty,
          'unit_price': unit,
          'price': unit,
          if (itemTax != null) 'tax_rate': itemTax,
        };
        if (discountRaw != null) {
          final dval = discountRaw is num
              ? discountRaw.toDouble()
              : double.tryParse(discountRaw.toString());
          if (dval != null) {
            double percent;
            if (dval <= 100.0 && dval >= 0.0) {
              percent = dval;
            } else {
              final base = (unit * qty);
              percent = base > 0 ? ((dval / base) * 100.0) : 0.0;
            }
            out['discount'] = percent.clamp(0.0, 100.0);
          }
        }
        items.add(out);
      }
    }
    if (items.isNotEmpty) payload['items'] = items;

    // Materials passthrough if present
    if (src['materials'] is List) payload['materials'] = src['materials'];
    if (src['measurements'] is List)
      payload['measurements'] = src['measurements'];

    return payload;
  }

  @override
  Future<List<InvoiceModel>> getInvoices({
    int page = 1,
    String? status,
  }) =>
      getList(
        ApiEndpoints.invoices,
        fromJson: InvoiceModel.fromJson,
        queryParams: {
          'page': page,
          if (status != null) 'status': status,
        },
      );

  @override
  Future<InvoiceModel> getInvoiceById(String id) => get(
        ApiEndpoints.invoice(id),
        fromJson: InvoiceModel.fromJson,
      );

  @override
  Future<InvoiceModel> createInvoice(Map<String, dynamic> data) async {
    final payload = _buildPayload(data);
    // Also include common aliases
    if (payload['items'] is List) {
      payload['line_items'] ??= payload['items'];
      payload['invoice_items'] ??= payload['items'];
    }
    payload['customer_uuid'] ??= payload['customer'];
    // Attempt 1: preferred payload
    try {
      assert(() {
        // ignore: avoid_print
        print('Invoice create attempt 1 payload: ' + payload.toString());
        return true;
      }());
      return await post(
        ApiEndpoints.invoices,
        data: payload,
        fromJson: InvoiceModel.fromJson,
      );
    } on DioException catch (e1) {
      // Attempt 2: switch items key to invoice_items only, switch date key to invoice_date
      try {
        final alt = Map<String, dynamic>.from(payload);
        if (alt['items'] != null) alt.remove('items');
        alt['invoice_items'] =
            payload['invoice_items'] ?? payload['line_items'];
        alt.remove('line_items');
        if (alt['issue_date'] != null) {
          alt['invoice_date'] = alt['issue_date'];
          alt.remove('issue_date');
        }
        assert(() {
          // ignore: avoid_print
          print('Invoice create attempt 2 payload: ' + alt.toString());
          return true;
        }());
        return await post(
          ApiEndpoints.invoices,
          data: alt,
          fromJson: InvoiceModel.fromJson,
        );
      } on DioException catch (e2) {
        // Attempt 3: use line_items only (remove invoice_items), restore issue_date
        try {
          final alt2 = Map<String, dynamic>.from(payload);
          if (alt2['items'] != null) alt2.remove('items');
          alt2['line_items'] =
              payload['line_items'] ?? payload['invoice_items'];
          alt2.remove('invoice_items');
          assert(() {
            // ignore: avoid_print
            print('Invoice create attempt 3 payload: ' + alt2.toString());
            return true;
          }());
          return await post(
            ApiEndpoints.invoices,
            data: alt2,
            fromJson: InvoiceModel.fromJson,
          );
        } on DioException catch (e3) {
          // Attach payload in error for easier diagnosis during development
          assert(() {
            // ignore: avoid_print
            print('Invoice create failed. e1: ${e1.response?.data}');
            print('Invoice create failed. e2: ${e2.response?.data}');
            print('Invoice create failed. e3: ${e3.response?.data}');
            return true;
          }());
          final withContext = DioException(
            requestOptions: e3.requestOptions,
            response: e3.response ?? e2.response ?? e1.response,
            type: e3.type,
            error:
                'Invoice create failed. Tried payload variants. Last payload: ${payload} | ${e3.error}',
            message: e3.message,
          );
          throw withContext;
        }
      }
    }
  }

  @override
  Future<InvoiceModel> updateInvoice(
      String id, Map<String, dynamic> data) async {
    final payload = _buildPayload(data);
    if (payload['items'] is List) {
      payload['invoice_items'] ??= payload['items'];
      payload['line_items'] ??= payload['items'];
    }
    payload['customer_uuid'] ??= payload['customer'];
    return put(
      ApiEndpoints.invoice(id),
      data: payload,
      fromJson: InvoiceModel.fromJson,
    );
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await deleteVoid(ApiEndpoints.invoice(id));
  }

  @override
  Future<void> sendInvoice(String id) async {
    await postVoid(ApiEndpoints.sendInvoice(id));
  }

  @override
  Future<InvoiceModel> markInvoiceAsPaid(
    String id,
    Map<String, dynamic> paymentData,
  ) =>
      post(
        ApiEndpoints.markInvoicePaid(id),
        data: paymentData,
        fromJson: InvoiceModel.fromJson,
      );

  @override
  Future<String> generateInvoicePdf(String id) async {
    final response = await dio.get(
      ApiEndpoints.invoicePdf(id),
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) {
      return ApiEndpoints.invoicePdf(id);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      message: 'Failed to generate PDF: ${response.statusCode}',
    );
  }

  @override
  Future<InvoiceDashboardModel> getDashboard() => get(
        ApiEndpoints.invoiceDashboard,
        fromJson: InvoiceDashboardModel.fromJson,
      );
}
