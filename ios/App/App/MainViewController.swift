import Capacitor
import UIKit

/**
 Não substitua `webView.navigationDelegate`: o Capacitor usa `webViewDelegationHandler`
 para política de navegação e para restaurar `isOpaque` após o primeiro load.
 Substituir esse delegate causava tela preta no lançamento.
 */
class MainViewController: CAPBridgeViewController {}
