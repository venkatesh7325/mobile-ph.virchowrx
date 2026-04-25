class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'MyApp';
  static const String appTagline = 'Your Business Partner';
  static const String version = 'Version 1.0.0';

  // Navigation / Menu
  static const String dashboard = 'Dashboard';
  static const String products = 'Products';
  static const String findDistributor = 'Find Distributor';
  static const String orders = 'Orders';
  static const String enquiry = 'Enquiry';
  static const String cart = 'Cart';
  static const String menu = 'Menu';
  static const String close = 'Close';
  static const String logout = 'Logout';
  static const String profile = 'Profile';
  static const String settings = 'Settings';

  // Dashboard
  static const String welcomeBack = 'Welcome back';
  static const String totalOrders = 'Total Orders';
  static const String totalRevenue = 'Total Revenue';
  static const String activeProducts = 'Active Products';
  static const String pendingEnquiries = 'Pending Enquiries';
  static const String recentOrders = 'Recent Orders';
  static const String quickStats = 'Quick Stats';
  static const String viewAll = 'View All';
  static const String today = 'Today';
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';

  // Products
  static const String allProducts = 'All Products';
  static const String searchProducts = 'Search products...';
  static const String productDetails = 'Product Details';
  static const String addToCart = 'Add to Cart';
  static const String outOfStock = 'Out of Stock';
  static const String inStock = 'In Stock';
  static const String productCode = 'Product Code';
  static const String category = 'Category';
  static const String price = 'Price';
  static const String quantity = 'Quantity';
  static const String noProductsFound = 'No products found';
  static const String filterProducts = 'Filter Products';
  static const String sortBy = 'Sort By';

  // Find Distributor
  static const String findDistributorTitle = 'Find Distributor';
  static const String searchDistributor = 'Search by location or name...';
  static const String nearbyDistributors = 'Nearby Distributors';
  static const String allDistributors = 'All Distributors';
  static const String noDistributorsFound = 'No distributors found';
  static const String contactDistributor = 'Contact Distributor';
  static const String viewOnMap = 'View on Map';
  static const String distance = 'Distance';
  static const String rating = 'Rating';
  static const String openNow = 'Open Now';

  // Orders
  static const String myOrders = 'My Orders';
  static const String orderDetails = 'Order Details';
  static const String orderId = 'Order ID';
  static const String orderDate = 'Order Date';
  static const String orderStatus = 'Order Status';
  static const String trackOrder = 'Track Order';
  static const String reorder = 'Reorder';
  static const String noOrdersFound = 'No orders found';
  static const String pending = 'Pending';
  static const String processing = 'Processing';
  static const String shipped = 'Shipped';
  static const String delivered = 'Delivered';
  static const String cancelled = 'Cancelled';
  static const String placeOrder = 'Place Order';
  static const String orderSummary = 'Order Summary';
  static const String subtotal = 'Subtotal';
  static const String shipping = 'Shipping';
  static const String tax = 'Tax';
  static const String total = 'Total';

  // Enquiry
  static const String enquiryTitle = 'Enquiry';
  static const String newEnquiry = 'New Enquiry';
  static const String myEnquiries = 'My Enquiries';
  static const String enquiryDetails = 'Enquiry Details';
  static const String subject = 'Subject';
  static const String message = 'Message';
  static const String submitEnquiry = 'Submit Enquiry';
  static const String enquirySubmitted = 'Enquiry submitted successfully';
  static const String noEnquiriesFound = 'No enquiries found';
  static const String open = 'Open';
  static const String resolved = 'Resolved';
  static const String enquiryType = 'Enquiry Type';
  static const String productEnquiry = 'Product Enquiry';
  static const String generalEnquiry = 'General Enquiry';
  static const String priceEnquiry = 'Price Enquiry';

  // Cart
  static const String myCart = 'My Cart';
  static const String cartEmpty = 'Your cart is empty';
  static const String cartEmptyMessage = 'Add products to your cart to get started';
  static const String continueShopping = 'Continue Shopping';
  static const String checkout = 'Proceed to Checkout';
  static const String removeFromCart = 'Remove';
  static const String clearCart = 'Clear Cart';
  static const String itemsInCart = 'items in cart';
  static const String updateQuantity = 'Update Quantity';
  static const String cartTotal = 'Cart Total';
  static const String proceedToCheckout = 'Proceed to Checkout';

  // Common Actions
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String apply = 'Apply';
  static const String reset = 'Reset';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String share = 'Share';
  static const String download = 'Download';
  static const String refresh = 'Refresh';
  static const String retry = 'Retry';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String done = 'Done';
  static const String submit = 'Submit';
  static const String loading = 'Loading...';

  // Form Labels
  static const String name = 'Name';
  static const String email = 'Email';
  static const String phone = 'Phone';
  static const String address = 'Address';
  static const String city = 'City';
  static const String state = 'State';
  static const String pincode = 'Pincode';
  static const String country = 'Country';
  static const String description = 'Description';
  static const String remarks = 'Remarks';

  // Validation Messages
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String invalidPincode = 'Please enter a valid pincode';
  static const String minLength = 'Minimum 6 characters required';
  static const String passwordMismatch = 'Passwords do not match';

  // Error Messages
  static const String somethingWentWrong = 'Something went wrong';
  static const String networkError = 'No internet connection. Please check your network.';
  static const String serverError = 'Server error. Please try again later.';
  static const String timeoutError = 'Request timed out. Please try again.';
  static const String unauthorizedError = 'Session expired. Please login again.';
  static const String notFoundError = 'Resource not found.';

  // Success Messages
  static const String dataLoadedSuccess = 'Data loaded successfully';
  static const String orderPlacedSuccess = 'Order placed successfully!';
  static const String profileUpdatedSuccess = 'Profile updated successfully';
  static const String enquirySubmittedSuccess = 'Enquiry submitted successfully';
  static const String itemAddedToCart = 'Item added to cart';
  static const String itemRemovedFromCart = 'Item removed from cart';
}
