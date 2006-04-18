# Form implementation generated from reading ui file 'zipdialogui.ui'
#
# Created: Sun Apr 3 16:49:38 2005
#      by: The QtRuby User Interface Compiler (rbuic)
#
# WARNING! All changes made in this file will be lost!


require 'Qt'

class ZipDialogUI < Qt::Dialog

    attr_reader :entry_list_view
    attr_reader :add_button
    attr_reader :extract_button
    attr_reader :close_button


    def initialize(*k)
        super(*k)

        if name.nil?
        	setName("ZipDialogUI")
        end
        setSizeGripEnabled(true)

        @ZipDialogUILayout = Qt::HBoxLayout.new(self, 11, 6, 'ZipDialogUILayout')

        @entry_list_view = Qt::ListView.new(self, "entry_list_view")
        @entry_list_view.addColumn(trUtf8("Entry"))
        @entry_list_view.addColumn(trUtf8("Size"))
        @entry_list_view.setMinimumSize( Qt::Size.new(150, 200) )
        @entry_list_view.setResizePolicy( Qt::ScrollView::Manual )
        @entry_list_view.setSelectionMode( Qt::ListView::Extended )
        @entry_list_view.setResizeMode( Qt::ListView::AllColumns )
        @ZipDialogUILayout.addWidget(@entry_list_view)

        @layout2 = Qt::VBoxLayout.new(nil, 0, 6, 'layout2')

        @add_button = Qt::PushButton.new(self, "add_button")
        @add_button.setAutoDefault( true )
        @layout2.addWidget(@add_button)

        @extract_button = Qt::PushButton.new(self, "extract_button")
        @extract_button.setAutoDefault( true )
        @layout2.addWidget(@extract_button)
        @Spacer1 = Qt::SpacerItem.new(20, 160, Qt::SizePolicy::Minimum, Qt::SizePolicy::Expanding)
        @layout2.addItem(@Spacer1)

        @close_button = Qt::PushButton.new(self, "close_button")
        @close_button.setAutoDefault( true )
        @close_button.setDefault( true )
        @layout2.addWidget(@close_button)
        @ZipDialogUILayout.addLayout(@layout2)
        languageChange()
        resize( Qt::Size.new(416, 397).expandedTo(minimumSizeHint()) )
        clearWState( WState_Polished )

        Qt::Object.connect(@close_button, SIGNAL("clicked()"), self, SLOT("accept()") )
    end

    #
    #  Sets the strings of the subwidgets using the current
    #  language.
    #
    def languageChange()
        setCaption(trUtf8("Rubyzip"))
        @entry_list_view.header().setLabel( 0, trUtf8("Entry") )
        @entry_list_view.header().setLabel( 1, trUtf8("Size") )
        @add_button.setText( trUtf8("&Add...") )
        @add_button.setAccel( Qt::KeySequence.new(trUtf8("Alt+A")) )
        @extract_button.setText( trUtf8("&Extract...") )
        @extract_button.setAccel( Qt::KeySequence.new(trUtf8("Alt+E")) )
        @close_button.setText( trUtf8("&Close") )
        @close_button.setAccel( Qt::KeySequence.new(trUtf8("Alt+C")) )
    end
    protected :languageChange


end
