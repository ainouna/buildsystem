# -*- coding: utf-8 -*-
from Plugins.Plugin import PluginDescriptor
from Screens.Screen import Screen
#from Screens.HelpMenu import HelpableScreen
from Screens.MessageBox import MessageBox
from Screens.ChoiceBox import ChoiceBox
from Screens.Standby import TryQuitMainloop
from enigma import evfd
from time import localtime, strftime, sleep
from Components.Console import Console
from Tools.Directories import fileExists, resolveFilename, SCOPE_LANGUAGE, SCOPE_PLUGINS
from os import environ, statvfs
from Components.ActionMap import ActionMap
from Components.config import *
from Components.ConfigList import ConfigList, ConfigListScreen
from Components.Label import Label
#from Components.Pixmap import Pixmap, MultiPixmap
from Components.Language import language
from Components.Sources.StaticText import StaticText
#from Tools.LoadPixmap import LoadPixmap
import os
#from Components.AVSwitch import AVSwitch
from Tools.HardwareInfo import HardwareInfo
import gettext
#Version 210115.2

lang = language.getLanguage()
environ['LANGUAGE'] = lang[:2]
gettext.bindtextdomain('enigma2', resolveFilename(SCOPE_LANGUAGE))
gettext.textdomain('enigma2')
gettext.bindtextdomain('Systemoptions', '%s%s' % (resolveFilename(SCOPE_PLUGINS), 'Extensions/Systemoptions/locale/'))

def _(txt):
	t = gettext.dgettext('Systemoptions', txt)
	if t == txt:
		t = gettext.gettext(txt)
	return t

def translateBlock(block):
	for x in TranslationHelper:
		if block.__contains__(x[0]):
			block = block.replace(x[0], x[1])
	return block

pll0 = '/proc/cpu_frequ/pll0_ndiv_mdiv'
#path = '/usr/lib/enigma2/python/Plugins/Extensions/Systemoptions/images/'
stb = HardwareInfo().get_device_name()

config.plugins.systemoptions = ConfigSubsection()
config.plugins.systemoptions.wlan = ConfigSelection(default='0',
	choices=[
		('0', 'none'),
		('mt7601Usta', 'MT7601U'),
		('8188eu', 'RTL8188EU'),
		('8192cu', 'RTL8192CU'),
		('8192du', 'RTL8192DU'),
		('8192eu', 'RTL8192EU'),
		('8712u', 'RT8712U'),
		('rt2870sta', 'RT2870STA'),
		('rt3070sta', 'RT3070STA'),
		('rt5370sta', 'RT5370STA')
		])
config.plugins.systemoptions.autologin = ConfigSelection(default='yes',
	choices = [
		('yes', _('yes')),
		('no', _('no'))
		])
#config.plugins.systemoptions.swap = ConfigYesNo(default=False)
config.plugins.systemoptions.swap = ConfigSelection(default='no',
	choices = [
		('yes', _('yes')),
		('no', _('no'))
		])
config.plugins.systemoptions.swapsize = ConfigSelection(default='32768',
	choices = [
		('32768', _('32 Mbyte')),
		('65536', _('64 Mbyte')),
		('131072', _('128 Mbyte'))
		])
if os.path.isfile("/sbin/ntpdate"):
	config.plugins.systemoptions.inettime = ConfigSelection(default='yes',
		choices = [
			('yes', _('yes')),
			('no', _('no'))
			])
if os.path.isfile("/etc/init.d/sshd"):
	config.plugins.systemoptions.openssh = ConfigSelection(default='no',
		choices = [
			('yes', _('yes')),
			('no', _('no'))
		])
if os.path.isfile("/usr/bin/inadyn"):
	config.plugins.systemoptions.inadyn = ConfigSelection(default='no',
		choices = [
			('yes', _('yes')),
			('no', _('no'))
			])
if os.path.isfile("/lib/modules/cifs.ko"):
	config.plugins.systemoptions.cifs = ConfigSelection(default='no',
		choices = [
			('yes', _('yes')),
			('no', _('no'))
			])
if os.path.isfile("/boot/audio_dts.elf"):
	config.plugins.systemoptions.dtsdownmix = ConfigSelection(default='on',
		choices = [
			('on', _('on')),
			('off', _('off'))
			])
#if stb.lower() == 'hdbox':
#	hdbox specific options go here
if stb.lower() == 'spark7162' or stb.lower() == 'spark':
	config.plugins.systemoptions.tunertype = ConfigSelection(default='t',
		choices = [
			('t', _('terrestrial (DVB-T)')),
			('c', _('cable (DVB-C)'))
			])
	config.plugins.systemoptions.freq = ConfigSelection(default='540',
		choices = [
			('200', _('200 MHz')),
			('300', _('300 MHz')),
			('450', _('450 MHz')),
			('500', _('500 MHz')),
			('540', _('540 MHz (default)')),
			('600', _('600 MHz')),
			('630', _('630 MHz')),
			('650', _('650 MHz')),
			('700', _('700 MHz')),
			('710', _('710 MHz')),
			('775', _('775 MHz')),
			('800', _('800 MHz'))
			])
	config.plugins.systemoptions.stbyfreq = ConfigSelection(default='540',
		choices = [
			('200', _('200 MHz')),
			('300', _('300 MHz')),
			('450', _('450 MHz')),
			('500', _('500 MHz')),
			('540', _('540 MHz (default)'))
			])
config.plugins.systemoptions.extMenu = ConfigYesNo(default=True)

config.plugins.wireless = ConfigSubsection()
config.plugins.wireless.essid = ConfigText(default='your ssid', fixed_size=False)

config.plugins.wireless.encryption = ConfigSubsection()
config.plugins.wireless.encryption.type = ConfigSelection(default='no',
	choices=[
		'no',
		'WEP',
		'WPA',
		'WPA2-AES',
		'WPA2-TKIP'
		])
config.plugins.wireless.encryption.wepkeyindex = ConfigSelection(default='1',
	choices=[
		'1',
		'2',
		'3',
		'4'
		])
config.plugins.wireless.encryption.key = ConfigPassword(default='your pass phrase or key', fixed_size=False)

config.plugins.wireless.settings = ConfigSubsection()
config.plugins.wireless.settings.LinkMode = ConfigSelection(default='Infrastructure',
	choices=[
		('Infrastructure', _('infrastructure')),
		('Adhoc', _('adhoc'))
		])
config.plugins.wireless.settings.WMode = ConfigSelection(default='11b/g/n-mixed',
	choices=[
		('A', _('11a-only')),
		('ABG', _('11a/b/g-mixed')),
		('ABGN', _('11a/b/g/n-mixed')),
		('AGN',_('11a/g/n-mixed')),
		('AN',_('11a/n-mixed')),
		('B', _('11b-only')),
		('BG', _('11b/g-mixed')),
		('BGN', _('11b/g/n-mixed')),
		('G', _('11g-only')),
		('GN', _('11g/n-mixed')),
		('N',_('11n-only'))
		])
config.plugins.wireless.settings.TxPower = ConfigSelection(default='100',
	choices=[
		('20', _('20%')),
		('40', _('40%')),
		('60', _('60%')),
		('80', _('80%')),
		('100', _('100%'))
		])

config.plugins.wireless.adapter = ConfigSubsection()
config.plugins.wireless.adapter.dhcp = ConfigYesNo(default=True)
config.plugins.wireless.adapter.ipaddress = ConfigIP(default=[192,168,178,100])
config.plugins.wireless.adapter.mask = ConfigIP(default=[255,255,255,0])
config.plugins.wireless.adapter.gateway = ConfigIP(default=[192,168,178,1])

class ConfigOptions(Screen, ConfigListScreen):
#	skin = """
#		<screen name="System_option_configuration" position="160,150" size="450,200" title="Spark 7162 option configuration">
#			<ePixmap pixmap="skin_default/buttons/red.png" position="10,0" size="140,40" alphatest="on" />
#			<ePixmap pixmap="skin_default/buttons/green.png" position="190,0" size="140,40" alphatest="on" />
#			<ePixmap pixmap="skin_default/buttons/yellow.png" position="470,0" size="140,40" alphatest="on" />
#			<ePixmap pixmap="skin_default/buttons/blue.png" position="650,0" size="140,40" alphatest="on" />
#			<widget source="key_red" render="Label" position="10,0" zPosition="1" size="140,40" font="Regular;20" halign="center" valign="center" backgroundColor="#9f1313" transparent="1" />
#			<widget source="key_green" render="Label" position="190,0" zPosition="1" size="140,40" font="Regular;20" halign="center" valign="center" backgroundColor="#1f771f" transparent="1" />
#			<widget source="key_yellow" render="Label" position="470,0" zPosition="1" size="140,40" font="Regular;20" halign="center" valign="center" backgroundColor="#9f1313" transparent="1" />
#			<widget source="key_blue" render="Label" position="650,0" zPosition="1" size="140,40" font="Regular;20" halign="center" valign="center" backgroundColor="#1f771f" transparent="1" />
#			<widget name="config" position="10,44" size="430,146" />
#		</screen>"""

#	skin = """
#	<screen name="FlashBackup" position="center,center" size="700,300" title="Overclock settings" flags="wfNoBorder" backgroundColor="black">
#		<eLabel position="21,12" size="658,50" text="Overclock settings" font="Regular; 30" valign="center" transparent="1" backgroundColor="black" />
#		<eLabel position="21,100" size="658,1" backgroundColor="white" />
#		<eLabel position="21,60" size="658,50" text="Settings:" font="Regular; 18" valign="center" transparent="1" backgroundColor="black" />
#		<widget name="config" position="21,110" size="658,100" scrollbarMode="showOnDemand" />
#		<eLabel position="37,255" size="150,5" backgroundColor="red" />
#		<eLabel position="196,255" size="150,5" backgroundColor="green" />
#		<eLabel position="355,255" size="150,5" backgroundColor="yellow" />
#		<eLabel position="514,255" size="150,5" backgroundColor="blue" />
#		<eLabel font="Regular; 20" foregroundColor="white" backgroundColor="black" halign="center" position="37,259" size="150,33" text="Cancel" transparent="1" />
#		<eLabel font="Regular; 20" foregroundColor="white" backgroundColor="black" halign="center" position="196,259" size="150,33" text="OK" transparent="1" />
#		<eLabel font="Regular; 20" foregroundColor="white" backgroundColor="black" halign="center" position="355,259" size="150,33" text="Save stby.freq" transparent="1" />
#		<eLabel font="Regular; 20" foregroundColor="white" backgroundColor="black" halign="center" position="514,259" size="150,33" text="Test" transparent="1" />
#		<widget name="OptionVersion" position="279,11" size="400,30" backgroundColor="black" foregroundColor="white" transparent="1" halign="right" />
#	</screen>"""

#	skin = """
#	<screen name="Setupp" title="Setup" position="fill" flags="wfNoBorder">
#		<panel name="PigTemplate"/>
#		<panel name="ButtonTemplate_4S"/>
#		<!--widget name="HelpWindow" pixmap="skin_default/vkey_icon.png" position="50,410" zPosition="1" size="1,1" transparent="1" alphatest="on" /-->
#		<widget name="config" position="530,110" size="690,500" scrollbarMode="showOnDemand" selectionPixmap="PLi-HD/buttons/sel.png" />
#	</screen>
#	<screen name="PigTemplate">
#		<panel name="SelectionTemplate"/>
#		<ePixmap pixmap="PLi-HD/logos/pli.png" position="85,590" size="135,34" alphatest="on" />
#	</screen>"""

	skin = """
	<screen name="dummy" title="Setup" position="fill" flags="wfNoBorder">
		<eLabel text="System options configuration" position="85,30" size="1085,55" backgroundColor="secondBG" transparent="1" zPosition="1" font="Regular;24" valign="center" halign="left" />
	</screen>"""

	def __init__(self, session):
	        Screen.__init__(self, session)
	        self.session = session
#		self.version = 'V1.1'
#		self['OptionVersion'] = Label(_(self.version + ' by Audioniek'))
		self.skinName = ["PartnerboxEntryConfigScreen"]
#		self.skinName = ["Setup"]
		self.setTitle(_("System options configuration"))
		self["key_red"] = self["red"] = Label(_("Cancel"))
		if stb.lower() == 'spark7162' or stb.lower() == 'spark':
			self["key_green"] = self["green"] = Label(_("OK (reboots)"))
			self["key_blue"] = self["blue"] = Label(_("Test overclock"))
		else:
			self["key_green"] = self["green"] = Label(_("OK"))
		self["key_yellow"] = self["yellow"] = Label(_("Reboot receiver"))
#		self["key_red"] = StaticText(_("Cancel"))
#		self["key_green"] = StaticText(_("OK (reboots)"))
#		self["key_yellow"] = StaticText(_("Reboot receiver"))
#		self["key_blue"] = StaticText(_("Test overclock"))

	        self.cfglist = []
	        ConfigListScreen.__init__(self, self.cfglist)
		self.setTitle(_("System option configuration"))
#		self["OKCancelActions"] = ActionMap(self, "OkCancelActions",
#			{
#			"cancel": (self.cancel, _("Cancel Spark 7162 options configuration")),
#			"ok": (self.keySave, _("Store Spark 7162 options"))
#			})
#		self["ColorActions"] = ActionMap(self, "ColorActions",
#			{
#			"red": (self.cancel, _("Cancel Spark 7162 options configuration")),
#			"green": (self.keySave, _("Store Spark 7162 options and reboot receiver")),
#			"yellow": (self.keyYellow, _("Reboot receiver")),
#			"blue": (self.keyBlue, _("Test current overclock value"))
#			})
#		self["actions"] = ActionMap('SetupActions',
		if stb.lower() == 'spark7162' or stb.lower() == 'spark':
			self["actions"] = ActionMap(['OkCancelActions', 'DirectionActions', 'InputActions', 'ColorActions'],
				{
				'left': self.keyLeft,
				'down': self.keyDown,
				'up': self.keyUp,
				'right': self.keyRight,
				"cancel": self.cancel,
				"ok": self.keySave,
				"red": self.cancel,
				"green": self.keySaveSpark,
				"yellow": self.keyYellow,
				"blue": self.keyBlue
				}, -2)
		else:
			self["actions"] = ActionMap(['OkCancelActions', 'DirectionActions', 'InputActions', 'ColorActions'],
				{
				'left': self.keyLeft,
				'down': self.keyDown,
				'up': self.keyUp,
				'right': self.keyRight,
				"cancel": self.cancel,
				"ok": self.keySave,
				"red": self.cancel,
				"green": self.keySave,
				"yellow": self.keyYellow,
				}, -2)
#	        self.cfglist = []
#	        ConfigListScreen.__init__(self, self.cfglist)
		self.createSetup()
#		self.onLayoutFinish.append(self.layoutFinished)
#		self.onClose.append(self.cleanup)

#		self["HelpWindow"] = Pixmap()
#		self["HelpWindow"].hide()

	def createSetup(self):
		self.cfglist = []
		if stb.lower() == 'spark7162' or stb.lower() == 'spark':
			self.cfglist.append(getConfigListEntry(_('CPU clock frequency:'), config.plugins.systemoptions.freq))
			self.cfglist.append(getConfigListEntry(_('Standby clock frequency:'), config.plugins.systemoptions.stbyfreq))
		if stb.lower() == 'spark7162':
			self.cfglist.append(getConfigListEntry(_('Tuner C type:'), config.plugins.systemoptions.tunertype))
		if os.path.isfile("/boot/audio_dts.elf"):
			listadd = [getConfigListEntry(_('DTS downmix:'), config.plugins.systemoptions.dtsdownmix)]
			self.cfglist.extend(listadd)
		if os.path.isfile("/sbin/ntpdate"):
			listadd = [getConfigListEntry(_('Synchronise with internet time:'), config.plugins.systemoptions.inettime)]
			self.cfglist.extend(listadd)
		self.cfglist.append(getConfigListEntry(_('Enable auto telnet login:'), config.plugins.systemoptions.autologin))
		self.cfglist.append(getConfigListEntry(_('Enable swap:'), config.plugins.systemoptions.swap))
		self.swap_enable = config.plugins.systemoptions.swap.value
		if self.swap_enable == "yes":
			listadd = [getConfigListEntry(_('Swap size:'), config.plugins.systemoptions.swapsize)]
			self.cfglist.extend(listadd)
		if os.path.isfile("/etc/init.d/sshd"):
			listadd = [getConfigListEntry(_('Enable OpenSSH:'), config.plugins.systemoptions.openssh)]
			self.cfglist.extend(listadd)
		if os.path.isfile("/usr/bin/inadyn"):
			listadd = [getConfigListEntry(_('Enable inadyn:'), config.plugins.systemoptions.inadyn)]
			self.cfglist.extend(listadd)
		if os.path.isfile("/lib/modules/cifs.ko"):
			listadd = [getConfigListEntry(_('Enable CIFS:'), config.plugins.systemoptions.cifs)]
			self.cfglist.extend(listadd)
		self.cfglist.append(getConfigListEntry(_('WLAN driver:'), config.plugins.systemoptions.wlan))
		self.wlan_driver = config.plugins.systemoptions.wlan.value
		if self.wlan_driver != "0":
			listadd = [getConfigListEntry(_('  SSID:'), config.plugins.wireless.essid)]
			self.cfglist.extend(listadd)
			listadd = [getConfigListEntry(_('  Link mode:'), config.plugins.wireless.settings.LinkMode)]
			self.cfglist.extend(listadd)
			listadd = [getConfigListEntry(_('  Mode:'), config.plugins.wireless.settings.WMode)]
			self.cfglist.extend(listadd)
			listadd = [getConfigListEntry(_('  Transmitting power:'), config.plugins.wireless.settings.TxPower)]
			self.cfglist.extend(listadd)
			listadd = [getConfigListEntry(_('  Encryption:'), config.plugins.wireless.encryption.type)]
			self.cfglist.extend(listadd)
#encryption section
			self.wlan_encryption = config.plugins.wireless.encryption.type.value
			if self.wlan_encryption != "no":
				if self.wlan_encryption == "WPA2-AES":
					listadd = [getConfigListEntry(_('    Pass phrase:'), config.plugins.wireless.encryption.key)]
				if self.wlan_encryption != "WPA2-AES":
					listadd = [getConfigListEntry(_('    Encryption key:'), config.plugins.wireless.encryption.key)]
				self.cfglist.extend(listadd)
				if self.wlan_encryption == "WEP":
					listadd = [getConfigListEntry(_('    WEP key index:'), config.plugins.wireless.encryption.wepkeyindex)]
					self.cfglist.extend(listadd)
#DHCP yes/no
			self.cfglist.append(getConfigListEntry(_('  DHCP:'), config.plugins.wireless.adapter.dhcp))
			self.wlan_dhcp = config.plugins.wireless.adapter.dhcp.value
			if self.wlan_dhcp == False:
				listadd = [getConfigListEntry(_('    IP address:'), config.plugins.wireless.adapter.ipaddress)]
				self.cfglist.extend(listadd)
				listadd = [getConfigListEntry(_('    Netmask:'), config.plugins.wireless.adapter.mask)]
				self.cfglist.extend(listadd)
				listadd = [getConfigListEntry(_('    Gateway IP address:'), config.plugins.wireless.adapter.gateway)]
				self.cfglist.extend(listadd)
		self.cfglist.append(getConfigListEntry(_('Show this plugin in plugin menu'), config.plugins.systemoptions.extMenu))
		self["config"].setList(self.cfglist)

	def cancel(self):
		ConfigListScreen.keyCancel(self)

	def keySave(self):
		ConfigListScreen.keySave(self)
		if config.plugins.systemoptions.swap.value == True:
			dummy = open('/tmp/setswap', 'a')
	 		self.close()

	def keySaveSpark(self):
		ConfigListScreen.keySave(self)
		if config.plugins.systemoptions.swap.value == True:
			dummy = open('/tmp/setswap', 'a')
	 		self.close()
		restartbox = self.session.openWithCallback(self.restartE2, MessageBox, _('The receiver needs to be restarted to apply the new options.\n \nRebooting in a moment!\n'), MessageBox.TYPE_INFO, timeout=8)
		restartbox.setTitle(_('Reboot receiver'))

	def keyYellow(self):
		restartbox = self.session.openWithCallback(self.restartE2, MessageBox, _('Do you really want to restart the receiver now?'), MessageBox.TYPE_YESNO)
		restartbox.setTitle(_('Reboot receiver'))

	if stb.lower() == 'spark7162' or stb.lower() == 'spark':
		def keyBlue(self):
			#apply CPU clock frequency
			if config.plugins.systemoptions.freq.value:
				if config.plugins.systemoptions.freq.value == "200":
					overclk=5123
				elif config.plugins.systemoptions.freq.value == "300":
					overclk=2561
				elif config.plugins.systemoptions.freq.value == "450":
					overclk=3841
				elif config.plugins.systemoptions.freq.value == "500":
					overclk=12803
				elif config.plugins.systemoptions.freq.value == "540":
					overclk=4609
				elif config.plugins.systemoptions.freq.value == "600":
					overclk=5121
				elif config.plugins.systemoptions.freq.value == "630":
					overclk=5377
				elif config.plugins.systemoptions.freq.value == "650":
					overclk=16643
				elif config.plugins.systemoptions.freq.value == "700":
					overclk=17923
				elif config.plugins.systemoptions.freq.value == "710":
					overclk=18179
				elif config.plugins.systemoptions.freq.value == "750":
					overclk=19203
				elif config.plugins.systemoptions.freq.value == "775":
					overclk=39686
				elif config.plugins.systemoptions.freq.value == "800":
					overclk=20483
			else:
				overclk=4609
			print "[System options] Clockspeed =", config.plugins.systemoptions.freq.value, "MHz, PLL =", str(overclk)
			open(pll0, 'w').write(str(overclk))

	def keyLeft(self):
		self["config"].handleKey(KEY_LEFT)
		self.createSetup()

	def keyRight(self):
		self["config"].handleKey(KEY_RIGHT)
		self.createSetup()

	def keyDown(self):
		self['config'].instance.moveSelection(self['config'].instance.moveDown)

	def keyUp(self):
		self['config'].instance.moveSelection(self['config'].instance.moveUp)

	def restartE2(self, answer):
		if answer is True:
			self.session.open(TryQuitMainloop, 2)
		else:
			self.close()

def opencfg(session, **kwargs):
		session.open(ConfigOptions)
#		evfd.getInstance().vfd_write_string( "System options" )

def Optionsmenu(menuid, **kwargs):
	if menuid == "system":
		return [(_("System options"), opencfg, "systemoptions_setting", 46)]
	else:
		return []

def Plugins(**kwargs):
	l = [PluginDescriptor(
		name = _("System options"),
		description = _("System options configuration"),
		where = PluginDescriptor.WHERE_MENU,
		fnc = Optionsmenu)]
	if config.plugins.systemoptions.extMenu.value:
		l.append(PluginDescriptor(
			name = _("System options"),
			description = _("System configuration options"),
			where = PluginDescriptor.WHERE_PLUGINMENU,
#			icon = _("systemoptions.png"),
			fnc = opencfg))
	return l

