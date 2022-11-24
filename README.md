# Ikev2-Client-Configurator for Windows (10+)

Set a more secure Ikev2/IPSec VPN connection in Windows. Compatible with Strongswan. (EAP - Authentication)

##### Why more secure:

(source: https://docs.strongswan.org/docs/5.9/interop/windowsClients.html)
By default Windows 7 up to Windows 11 propose only the weak modp1024 Diffie-Hellman key exchange algorithm that has been deprecated by NIST Special Publication 800-57 Part 3 Revision 1 since 2015:
- This script:
    - Add a Registry Key to enable DH_2048 Key Exchange with AES256 authenticated encryption algorithm

In Windows unfortunately the ESP proposals still contain the weak single DES and even NULL encryption algorithms and data integrity is restricted to SHA1
- This Script enforces:
  -DHGroup ECP384 
  -IntegrityCheckMethod SHA384 
  -PfsGroup ECP384 
  -EncryptionMethod GCMAES256

##### Why more simple:

It simplifies the import of CA-Cert: It's only needed an "Open File and Select".

##### Usage:

1. Open .exe file
2. Import CA-Certificate (Eg .pem certificate from strongswan-pki)
3. Set VPN Name and IP/Domain
4. Enjoy.


Exe created with PS2EXE by MScholtes; link: https://github.com/MScholtes/PS2EXE
(Many Thanks!)

##### Note:

The software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. in no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.

##### Known Limitations:

No GUI available. Powershell 5.0 (maybe +) required. 
Only Ikev2 possible.
Only EAP authentication.
Not a really fancy shell.
Maybe more.

It needs a lot of work to make it prettier and with more features but even with this limitations, it basically does the job.

##### Note to Users and Readers:
Even though I do not work as a computer engineer and I have not much time to spend in this project, please let me know of any bugs or problems of any kind. 
Feel free to fork and develop.
For the experts: Please, be kind if any blunders. Thanks.
