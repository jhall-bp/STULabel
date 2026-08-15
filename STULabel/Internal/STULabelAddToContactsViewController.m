// Copyright 2018 Stephan Tolksdorf

#import "STULabelAddToContactsViewController.h"

#import <ContactsUI/ContactsUI.h>

@interface STULabelAddToContactsViewController() <CNContactViewControllerDelegate>
@end
@implementation STULabelAddToContactsViewController

- (instancetype)initWithContact:(CNContact *)contact {
  __auto_type* const cvc = [CNContactViewController viewControllerForUnknownContact:contact];
  cvc.contactStore = [[CNContactStore alloc] init];
  cvc.allowsActions = false;
  if ((self = [super initWithRootViewController:cvc])) {
    cvc.delegate = self;
  }
  return self;
}

- (CGSize)preferredContentSize {
  return CGSizeMake(360, 480);
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // When this view controller is presented in a popover it doesn't need a cancel button.
  self.viewControllers[0].navigationItem.rightBarButtonItem =
    self.popoverPresentationController.arrowDirection != UIPopoverArrowDirectionUnknown ? nil
    : [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                    target:self action:@selector(stu_cancel)];
}

- (void)contactViewController:(CNContactViewController * __unused)viewController
       didCompleteWithContact:(nullable CNContact * __unused)contact
{
  [self dismissViewControllerAnimated:true completion:nil];
}

- (void)stu_cancel {
  [self dismissViewControllerAnimated:true completion:nil];
}

@end
